import Testing

@testable import SwitcherCore

@MainActor
@Suite("Switcher coordinator")
struct SwitcherCoordinatorTests {
    private func application(_ raw: Int32) -> SwitchableApplication {
        SwitchableApplication(
            pid: ProcessIdentifier(rawValue: raw),
            bundleIdentifier: "test.\(raw)",
            name: "App \(raw)",
            isActive: false,
            windows: []
        )
    }

    private final class ActivationSpy {
        var raised: [SwitcherTarget] = []
        var succeeds = true

        func activate(_ target: SwitcherTarget) -> Bool {
            raised.append(target)
            return succeeds
        }
    }

    private func coordinator(
        _ pids: [Int32],
        order: MRUOrder = MRUOrder(),
        activator: ActivationSpy = ActivationSpy()
    ) -> SwitcherCoordinator {
        SwitcherCoordinator(
            order: order,
            snapshot: { SpaceInventory(applications: pids.map(self.application), layer: .onScreen) },
            activate: { activator.activate($0) }
        )
    }

    @Test("an empty Space opens a session of its own instead of releasing the key")
    func emptySpaceOpens() {
        let activator = ActivationSpy()
        let coordinator = coordinator([], activator: activator)
        #expect(coordinator.handle(.activate(.forward, .applications)) == .opened)
        #expect(coordinator.session?.isEmpty == true)
        #expect(coordinator.handle(.commit) == .cancelled)
        #expect(activator.raised.isEmpty)
    }

    @Test("a session opens over the snapshot ordered by recent use")
    func opensOverOrderedSnapshot() {
        let coordinator = coordinator([1, 2, 3], order: MRUOrder(seed: [3, 2, 1].map(ProcessIdentifier.init)))
        #expect(coordinator.handle(.activate(.forward, .applications)) == .opened)
        #expect(coordinator.session?.entries.map(\.application.pid.rawValue) == [3, 2, 1])
        #expect(coordinator.session?.selection == 1)
    }

    @Test("an activation recorded during a session reorders only the next one")
    func activationAppliesToTheNextSession() {
        let coordinator = coordinator([1, 2])
        _ = coordinator.handle(.activate(.forward, .applications))
        coordinator.recordActivation(of: ProcessIdentifier(rawValue: 2))
        #expect(coordinator.session?.entries.map(\.application.pid.rawValue) == [1, 2])
        _ = coordinator.handle(.commit)
        _ = coordinator.handle(.activate(.forward, .applications))
        #expect(coordinator.session?.entries.map(\.application.pid.rawValue) == [2, 1])
    }

    @Test("the session is open only between activation and commit")
    func reportsSessionState() {
        let coordinator = coordinator([1, 2, 3])
        #expect(coordinator.isSessionOpen == false)
        _ = coordinator.handle(.activate(.forward, .applications))
        #expect(coordinator.isSessionOpen)
        #expect(coordinator.handle(.step(.forward)) == .moved)
        #expect(coordinator.handle(.commit) == .committed(SwitcherTarget(pid: ProcessIdentifier(rawValue: 3))))
        #expect(coordinator.isSessionOpen == false)
    }

    @Test("cancelling ends the session without choosing anything")
    func cancelEndsSession() {
        let coordinator = coordinator([1, 2])
        _ = coordinator.handle(.activate(.forward, .applications))
        #expect(coordinator.handle(.cancel) == .cancelled)
        #expect(coordinator.isSessionOpen == false)
    }

    @Test("committing raises the selected application once")
    func commitRaisesSelection() {
        let activator = ActivationSpy()
        let coordinator = coordinator([1, 2, 3], activator: activator)
        _ = coordinator.handle(.activate(.forward, .applications))
        _ = coordinator.handle(.step(.forward))
        #expect(coordinator.handle(.commit) == .committed(SwitcherTarget(pid: ProcessIdentifier(rawValue: 3))))
        #expect(activator.raised == [SwitcherTarget(pid: ProcessIdentifier(rawValue: 3))])
    }

    @Test("a commit the system refuses reports a failed activation")
    func failedActivationIsReported() {
        let activator = ActivationSpy()
        activator.succeeds = false
        let coordinator = coordinator([1, 2], activator: activator)
        _ = coordinator.handle(.activate(.forward, .applications))
        #expect(coordinator.handle(.commit) == .activationFailed(SwitcherTarget(pid: ProcessIdentifier(rawValue: 2))))
        #expect(coordinator.isSessionOpen == false)
    }

    @Test("nothing but a commit raises an application")
    func onlyCommitRaises() {
        let activator = ActivationSpy()
        let coordinator = coordinator([1, 2], activator: activator)
        #expect(coordinator.handle(.commit) == .ignored)
        _ = coordinator.handle(.activate(.forward, .applications))
        _ = coordinator.handle(.step(.forward))
        _ = coordinator.handle(.cancel)
        #expect(activator.raised.isEmpty)
    }

    @Test("an application session records its own scope")
    func applicationSessionScope() {
        let coordinator = coordinator([1, 2])
        _ = coordinator.handle(.activate(.forward, .applications))
        #expect(coordinator.session?.scope == .applications)
    }
}
