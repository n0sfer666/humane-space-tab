import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Overlay controller")
struct OverlayControllerTests {
    private func model(_ selection: Int) -> OverlayModel {
        OverlayModel(
            applications: (0..<3).map {
                SwitchableApplication(
                    pid: ProcessIdentifier(rawValue: Int32($0 + 1)),
                    bundleIdentifier: nil,
                    name: "App \($0)",
                    isActive: false,
                    windows: []
                )
            },
            selection: selection
        )
    }

    private func make() -> Fixture {
        let surface = OverlaySurfaceSpy()
        let scheduler = ManualOverlayScheduler()
        let watchdog = ManualOverlayScheduler()
        return Fixture(
            controller: OverlayController(surface: surface, scheduler: scheduler, watchdog: watchdog),
            surface: surface,
            scheduler: scheduler,
            watchdog: watchdog
        )
    }

    @Test("an opened session schedules the ribbon instead of showing it")
    func openSchedules() {
        let fixture = make()
        fixture.controller.render(model(1))
        #expect(fixture.surface.shown.isEmpty)
        #expect(fixture.scheduler.delays == [OverlayController.revealDelay])
    }

    @Test("a session that ends before the delay never shows anything")
    func quickSessionShowsNothing() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.controller.render(nil)
        fixture.scheduler.fire()
        #expect(fixture.surface.shown.isEmpty)
        #expect(fixture.surface.hides == 0)
    }

    @Test("the ribbon appears once when the delay elapses on an open session")
    func delayReveals() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.scheduler.fire()
        #expect(fixture.surface.shown.count == 1)
        #expect(fixture.surface.shown.first?.selection == 1)
    }

    @Test("stepping before the delay reveals the latest selection once")
    func stepBeforeDelay() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.controller.render(model(2))
        fixture.scheduler.fire()
        #expect(fixture.surface.shown.count == 1)
        #expect(fixture.surface.shown.first?.selection == 2)
        #expect(fixture.scheduler.delays.count == 1)
    }

    @Test("stepping while visible updates the ribbon instead of showing it again")
    func stepWhileVisible() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.scheduler.fire()
        fixture.controller.render(model(2))
        #expect(fixture.surface.shown.count == 1)
        #expect(fixture.surface.updated.map(\.selection) == [2])
    }

    @Test("ending a visible session hides the ribbon")
    func endHides() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.scheduler.fire()
        fixture.controller.render(nil)
        #expect(fixture.surface.hides == 1)
    }

    @Test("a second session schedules the ribbon again")
    func secondSession() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.scheduler.fire()
        fixture.controller.render(nil)
        fixture.controller.render(model(1))
        #expect(fixture.scheduler.delays.count == 2)
        fixture.scheduler.fire()
        #expect(fixture.surface.shown.count == 2)
    }

    @Test("a ribbon nobody touches is dismissed before it can wedge the screen")
    func idleRibbonIsDismissed() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.scheduler.fire()
        #expect(fixture.watchdog.delays == [OverlayController.idleLimit])
        fixture.watchdog.fire()
        #expect(fixture.surface.hides == 1)
    }

    @Test("stepping postpones the dismissal")
    func steppingRearmsTheWatchdog() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.scheduler.fire()
        fixture.controller.render(model(2))
        #expect(fixture.watchdog.delays.count == 2)
        #expect(fixture.surface.hides == 0)
    }

    @Test("a dismissed ribbon is not hidden a second time when the session ends")
    func dismissalHidesOnce() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.scheduler.fire()
        fixture.watchdog.fire()
        fixture.controller.render(nil)
        #expect(fixture.surface.hides == 1)
    }

    @Test("an invisible ribbon is never dismissed by the watchdog")
    func watchdogIgnoresAnInvisibleRibbon() {
        let fixture = make()
        fixture.controller.render(model(1))
        fixture.watchdog.fire()
        #expect(fixture.surface.hides == 0)
    }
}
