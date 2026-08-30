import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Permission centre")
struct PermissionCenterTests {
    @MainActor
    private final class Fixture {
        let authority = AccessibilityAuthorityStub()
        let engine = HotkeyEngineStub()
        let log = LogSpy()
        var ticks: [@MainActor () -> Void] = []
        lazy var center = PermissionCenter(
            authority: authority,
            engine: engine,
            log: log,
            poll: { [unowned self] work in self.ticks.append(work) }
        )

        func tick() {
            let pending = ticks
            ticks = []
            for work in pending { work() }
        }
    }

    @Test("starting without the permission publishes the blocked state and arms the timer")
    func startsBlocked() {
        let fixture = Fixture()
        var published: [PermissionState] = []
        fixture.center.observe { published.append($0) }
        fixture.center.start()
        #expect(fixture.engine.starts == 1)
        #expect(published == [.blocked(canAsk: true)])
        #expect(fixture.ticks.count == 1)
    }

    @Test("a timer that finds no permission arms itself again without touching the tap")
    func pollWhileStillBlocked() {
        let fixture = Fixture()
        fixture.center.start()
        fixture.tick()
        #expect(fixture.engine.starts == 1)
        #expect(fixture.ticks.count == 1)
        #expect(fixture.center.state == .blocked(canAsk: true))
    }

    @Test("a granted permission rebuilds the tap and stops the timer")
    func pollAfterAGrant() {
        let fixture = Fixture()
        var published: [PermissionState] = []
        fixture.center.observe { published.append($0) }
        fixture.center.start()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        fixture.tick()
        #expect(fixture.engine.stops == 1)
        #expect(fixture.engine.starts == 2)
        #expect(published == [.blocked(canAsk: true), .intercepting])
        #expect(fixture.ticks.isEmpty)
    }

    @Test("starting with the permission in place arms no timer")
    func startsTrusted() {
        let fixture = Fixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        fixture.center.start()
        #expect(fixture.center.state == .intercepting)
        #expect(fixture.ticks.isEmpty)
    }

    @Test("the first request shows the system prompt and the next one opens System Settings")
    func grantAsksOnce() {
        let fixture = Fixture()
        fixture.center.requestGrant()
        fixture.center.requestGrant()
        #expect(fixture.authority.prompts == 1)
        #expect(fixture.authority.settingsOpened == 1)
    }

    @Test("a suspended tap is not put back by a refresh that fires meanwhile")
    func refreshRespectsSuspension() {
        let fixture = Fixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        fixture.center.start()
        fixture.center.suspend()
        #expect(fixture.engine.stops == 1)
        fixture.center.refresh()
        fixture.center.rebuildTap()
        #expect(fixture.engine.starts == 1)
        #expect(fixture.center.state == .intercepting)
    }

    @Test("resuming builds the tap again and publishes what came back")
    func resumeRebuildsTheTap() {
        let fixture = Fixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        fixture.center.start()
        fixture.center.suspend()
        fixture.engine.tapWhenTrusted = .observe
        fixture.center.resume()
        #expect(fixture.engine.starts == 2)
        #expect(fixture.center.state == .observing)
    }

    @Test("a changed shortcut rebuilds the tap it is baked into")
    func rebuildAfterShortcutChange() {
        let fixture = Fixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        fixture.center.start()
        fixture.center.rebuildTap()
        #expect(fixture.engine.stops == 1)
        #expect(fixture.engine.starts == 2)
        #expect(fixture.center.state == .intercepting)
    }

    @Test("a permission revoked while the app ran is noticed on the next refresh")
    func refreshAfterRevocation() {
        let fixture = Fixture()
        fixture.authority.isTrusted = true
        fixture.engine.tapWhenTrusted = .intercept
        fixture.center.start()
        fixture.authority.isTrusted = false
        fixture.engine.tapWhenTrusted = nil
        fixture.center.refresh()
        #expect(fixture.center.state == .blocked(canAsk: true))
        #expect(fixture.ticks.count == 1)
    }
}
