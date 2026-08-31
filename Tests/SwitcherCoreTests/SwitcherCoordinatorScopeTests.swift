import Testing

@testable import SwitcherCore

@MainActor
@Suite("Switcher coordinator, window scope")
struct SwitcherCoordinatorScopeTests {
    private final class ActivationSpy {
        var raised: [SwitcherTarget] = []

        func activate(_ target: SwitcherTarget) -> Bool {
            raised.append(target)
            return true
        }
    }

    private func window(_ raw: UInt32) -> ApplicationWindow {
        ApplicationWindow(id: WindowIdentifier(rawValue: raw), visibility: .onScreen)
    }

    private func windowed(_ pid: Int32, _ windows: [ApplicationWindow]) -> SwitchableApplication {
        SwitchableApplication(
            pid: ProcessIdentifier(rawValue: pid),
            bundleIdentifier: "test.\(pid)",
            name: "App \(pid)",
            isActive: false,
            windows: windows
        )
    }

    private func cycling(_ applications: [SwitchableApplication], onSpace: [UInt32]) -> SwitcherCoordinator {
        let space = Set(onSpace.map(WindowIdentifier.init(rawValue:)))
        return SwitcherCoordinator(
            order: MRUOrder(seed: applications.map(\.pid)),
            snapshot: { SpaceInventory(applications: applications, windowsOnCurrentSpace: space, layer: .onScreen) },
            activate: { _ in true }
        )
    }

    @Test("the window shortcut cycles the windows of the front application only")
    func cyclesFrontApplicationWindows() {
        let coordinator = cycling(
            [windowed(1, [window(10), window(11)]), windowed(2, [window(20)])],
            onSpace: [10, 11, 20]
        )
        #expect(coordinator.handle(.activate(.forward, .frontWindows)) == .opened)
        #expect(coordinator.session?.entries.compactMap { $0.window?.id.rawValue } == [10, 11])
        #expect(coordinator.session?.selection == 1)
        #expect(coordinator.session?.scope == .frontWindows)
    }

    @Test("a front application with one window on this Space opens nothing")
    func refusesToOpenWithoutAChoice() {
        let coordinator = cycling([windowed(1, [window(10), window(11)])], onSpace: [10])
        #expect(coordinator.handle(.activate(.forward, .frontWindows)) == .ignored)
        #expect(coordinator.isSessionOpen == false)
    }

    @Test("committing a window session raises that window")
    func commitsAWindow() {
        let activator = ActivationSpy()
        let applications = [windowed(1, [window(10), window(11)])]
        let coordinator = SwitcherCoordinator(
            order: MRUOrder(seed: applications.map(\.pid)),
            snapshot: {
                SpaceInventory(
                    applications: applications,
                    windowsOnCurrentSpace: Set([10, 11].map(WindowIdentifier.init(rawValue:))),
                    layer: .onScreen
                )
            },
            activate: { activator.activate($0) }
        )
        _ = coordinator.handle(.activate(.forward, .frontWindows))
        _ = coordinator.handle(.commit)
        let target = SwitcherTarget(pid: ProcessIdentifier(rawValue: 1), window: WindowIdentifier(rawValue: 11))
        #expect(activator.raised == [target])
    }
}
