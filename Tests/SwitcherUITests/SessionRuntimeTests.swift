import SwitcherCore
import SystemPorts
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Session runtime")
struct SessionRuntimeTests {
    private final class TitleSourceStub: WindowTitleSource {
        func titles(of process: ProcessIdentifier, windows: [WindowIdentifier]) -> [WindowIdentifier: String] { [:] }
    }

    private final class ActivationSpy {
        var raised: [SwitcherTarget] = []
    }

    private struct Fixture {
        let runtime: SessionRuntime
        let surface: OverlaySurfaceSpy
        let scheduler: ManualOverlayScheduler
        let log: LogSpy
        let activations: ActivationSpy
    }

    private func applications(_ count: Int) -> [SwitchableApplication] {
        (0..<count).map {
            SwitchableApplication(
                pid: ProcessIdentifier(rawValue: Int32($0 + 1)),
                bundleIdentifier: "test.\($0)",
                name: "App \($0)",
                isActive: $0 == 0,
                windows: []
            )
        }
    }

    private func make(_ count: Int = 3) -> Fixture {
        let surface = OverlaySurfaceSpy()
        let scheduler = ManualOverlayScheduler()
        let log = LogSpy()
        let activations = ActivationSpy()
        let list = applications(count)
        let switcher = SwitcherCoordinator(
            snapshot: { SpaceInventory(applications: list, layer: .onScreen) },
            activate: { target in
                activations.raised.append(target)
                return true
            }
        )
        let presenter = SessionPresenter(
            overlay: OverlayController(
                surface: surface,
                scheduler: scheduler,
                watchdog: ManualOverlayScheduler()
            ),
            icons: IconSourceSpy(),
            titles: SessionTitles(source: TitleSourceStub())
        )
        return Fixture(
            runtime: SessionRuntime(switcher: switcher, presenter: presenter, log: log),
            surface: surface,
            scheduler: scheduler,
            log: log,
            activations: activations
        )
    }

    private func opened() -> Fixture {
        let fixture = make()
        fixture.runtime.perform(.activate(.forward, .applications))
        fixture.scheduler.fire()
        return fixture
    }

    @Test("the runtime names the scope of the session that is open")
    func reportsTheOpenScope() {
        let fixture = make()
        #expect(fixture.runtime.openScope == nil)
        fixture.runtime.perform(.activate(.forward, .applications))
        #expect(fixture.runtime.openScope == .applications)
        fixture.runtime.perform(.commit)
        #expect(fixture.runtime.openScope == nil)
    }

    @Test("a hover moves the selection and redraws the ribbon")
    func hoverMovesSelection() {
        let fixture = opened()
        fixture.runtime.handle(.select(2))
        #expect(fixture.surface.updated.last?.selection == 2)
        #expect(fixture.log.events.contains(.switcherSelectionMoved))
    }

    @Test("a hover on the tile already selected changes nothing")
    func hoverOnTheSelectedTileIsSilent() {
        let fixture = opened()
        let updates = fixture.surface.updated.count
        fixture.runtime.handle(.select(1))
        #expect(fixture.surface.updated.count == updates)
        #expect(fixture.log.events.contains(.switcherCommandIgnored) == false)
    }

    @Test("a click selects the tile and commits it")
    func clickCommits() {
        let fixture = opened()
        fixture.runtime.handle(.commit(2))
        #expect(fixture.activations.raised == [SwitcherTarget(pid: ProcessIdentifier(rawValue: 3))])
        #expect(fixture.surface.hides == 1)
        #expect(fixture.runtime.isSessionOpen == false)
    }

    @Test("a scroll steps the selection")
    func scrollSteps() {
        let fixture = opened()
        fixture.runtime.handle(.step(.backward))
        #expect(fixture.surface.updated.last?.selection == 0)
    }

    @Test("a gesture without a session does nothing")
    func gesturesNeedASession() {
        let fixture = make()
        fixture.runtime.handle(.select(1))
        fixture.runtime.handle(.step(.forward))
        fixture.runtime.handle(.commit(1))
        #expect(fixture.activations.raised.isEmpty)
        #expect(fixture.surface.shown.isEmpty)
        #expect(fixture.log.events.isEmpty)
    }
}
