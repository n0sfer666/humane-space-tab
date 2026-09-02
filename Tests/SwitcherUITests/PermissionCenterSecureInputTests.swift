import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Permission centre, secure input")
struct PermissionCenterSecureInputTests {
    private static let holder = SecureInputHolder(process: ProcessIdentifier(rawValue: 1210), name: "Ghostty")

    private func working() -> PermissionCenterFixture {
        let fixture = PermissionCenterFixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        return fixture
    }

    @Test("a password being typed changes nothing the user can see")
    func aShortHoldIsNotPublished() {
        let fixture = working()
        fixture.center.start()
        fixture.secureInput.holder = Self.holder
        fixture.tick(at: 1)
        fixture.tick(at: 3)
        #expect(fixture.center.state == .intercepting)
    }

    @Test("a hold that stands is published with the name of what is holding it")
    func aSettledHoldIsPublished() {
        let fixture = working()
        fixture.center.start()
        fixture.secureInput.holder = Self.holder
        fixture.tick(at: 1)
        fixture.tick(at: 4)
        #expect(fixture.center.state == .secured(by: "Ghostty"))
    }

    @Test("the hold ending puts the switcher back without rebuilding the tap")
    func aReleasedHoldRestoresTheState() {
        let fixture = working()
        fixture.center.start()
        fixture.secureInput.holder = Self.holder
        fixture.tick(at: 1)
        fixture.tick(at: 4)
        fixture.secureInput.holder = nil
        fixture.tick(at: 5)
        #expect(fixture.center.state == .intercepting)
        #expect(fixture.engine.starts == 1)
        #expect(fixture.engine.stops == 0)
    }

    @Test("secure input is what a tap left observing means, so it is the state reported")
    func aSettledHoldOutranksObservation() {
        let fixture = PermissionCenterFixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .observe
        fixture.center.start()
        fixture.secureInput.holder = Self.holder
        fixture.tick(at: 1)
        fixture.tick(at: 4)
        #expect(fixture.center.state == .secured(by: "Ghostty"))
    }

    @Test("a missing permission is the bigger problem and stays the one reported")
    func aBlockedStateOutranksSecureInput() {
        let fixture = PermissionCenterFixture()
        fixture.secureInput.holder = Self.holder
        fixture.center.start()
        fixture.tick(at: 1)
        fixture.tick(at: 4)
        #expect(fixture.center.state == .blocked(canAsk: true))
    }

    @Test("a hold already standing at launch is not reported until it has stood long enough")
    func aHoldPresentAtLaunchIsTimedFromLaunch() {
        let fixture = working()
        fixture.secureInput.holder = Self.holder
        fixture.center.start()
        #expect(fixture.center.state == .intercepting)
        fixture.tick(at: 3)
        #expect(fixture.center.state == .secured(by: "Ghostty"))
    }

    @Test("the timer keeps running while the permission is in place, because secure input can start at any time")
    func theTimerOutlivesTheGrant() {
        let fixture = working()
        fixture.center.start()
        #expect(fixture.ticks.count == 1)
        fixture.tick(at: 2)
        #expect(fixture.ticks.count == 1)
    }
}
