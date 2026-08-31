import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Permission centre, a deaf tap")
struct PermissionCenterDeafTests {
    @Test("a tap that receives no key presses is published as deaf, not as working")
    func deafTapIsPublished() {
        let fixture = PermissionCenterFixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        fixture.delivery.deliversKeyEvents = false
        var published: [PermissionState] = []
        fixture.center.observe { published.append($0) }
        fixture.center.start()
        #expect(published == [.blocked(canAsk: true), .deaf])
    }

    @Test("activating the app while the tap is deaf builds a new one")
    func refreshRebuildsADeafTap() {
        let fixture = PermissionCenterFixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        fixture.delivery.deliversKeyEvents = false
        fixture.center.start()
        fixture.center.refresh()
        #expect(fixture.engine.stops == 1)
        #expect(fixture.engine.starts == 2)
        #expect(fixture.center.state == .deaf)
    }

    @Test("activating the app while the tap works leaves it alone")
    func refreshLeavesAWorkingTapAlone() {
        let fixture = PermissionCenterFixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        fixture.center.start()
        fixture.center.refresh()
        #expect(fixture.engine.stops == 0)
        #expect(fixture.engine.starts == 1)
    }
}
