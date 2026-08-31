import SwitcherCore
import SystemPorts
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Session presenter")
struct SessionPresenterTests {
    private final class TitleSourceStub: WindowTitleSource {
        var answers: [WindowIdentifier: String] = [:]

        func titles(of process: ProcessIdentifier, windows: [WindowIdentifier]) -> [WindowIdentifier: String] {
            answers
        }
    }

    private struct Fixture {
        let presenter: SessionPresenter
        let surface: OverlaySurfaceSpy
        let scheduler: ManualOverlayScheduler
        let icons: IconSourceSpy
        let source: TitleSourceStub
    }

    private func make() -> Fixture {
        let surface = OverlaySurfaceSpy()
        let scheduler = ManualOverlayScheduler()
        let icons = IconSourceSpy()
        let source = TitleSourceStub()
        return Fixture(
            presenter: SessionPresenter(
                overlay: OverlayController(
                    surface: surface,
                    scheduler: scheduler,
                    watchdog: ManualOverlayScheduler()
                ),
                icons: icons,
                titles: SessionTitles(source: source)
            ),
            surface: surface,
            scheduler: scheduler,
            icons: icons,
            source: source
        )
    }

    /// A session is built the way the app builds one, since only the machine may open it.
    private func session() -> SwitcherSession? {
        let application = SwitchableApplication(
            pid: ProcessIdentifier(rawValue: 1),
            bundleIdentifier: nil,
            name: "Notes",
            isActive: false,
            windows: []
        )
        let window = ApplicationWindow(id: WindowIdentifier(rawValue: 10), visibility: .onScreen)
        let coordinator = SwitcherCoordinator(
            snapshot: { SpaceInventory(applications: [application], layer: .onScreen) },
            expand: { applications, _ in
                applications.flatMap {
                    [SwitcherEntry(application: $0, window: window), SwitcherEntry(application: $0)]
                }
            },
            activate: { _ in true }
        )
        _ = coordinator.handle(.activate(.forward, .applications))
        return coordinator.session
    }

    private func settle() async {
        for _ in 0..<8 { await Task.yield() }
    }

    @Test("an opened session loads its icons and shows the ribbon")
    func showsAnOpenedSession() {
        let fixture = make()
        fixture.presenter.show(session(), opened: true)
        fixture.scheduler.fire()
        #expect(fixture.surface.shown.count == 1)
        #expect(fixture.surface.shown.first?.entries.count == 2)
    }

    @Test("a title that arrives relabels the ribbon already on screen")
    func relabelsWithLateTitles() async {
        let fixture = make()
        fixture.source.answers = [WindowIdentifier(rawValue: 10): "Shopping list"]
        fixture.presenter.show(session(), opened: true)
        fixture.scheduler.fire()
        await settle()
        #expect(fixture.surface.updated.last?.titles.values.contains("Shopping list") == true)
    }

    @Test("the session that ends takes its titles with it")
    func forgetsTitlesWhenTheSessionEnds() async {
        let fixture = make()
        fixture.source.answers = [WindowIdentifier(rawValue: 10): "Shopping list"]
        fixture.presenter.show(session(), opened: true)
        fixture.presenter.show(nil, opened: false)
        await settle()
        #expect(fixture.surface.hides == 0)
        fixture.presenter.show(session(), opened: true)
        fixture.scheduler.fire()
        #expect(fixture.surface.shown.last?.titles.isEmpty == true)
    }
}
