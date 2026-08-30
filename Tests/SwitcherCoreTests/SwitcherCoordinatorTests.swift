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
        var raised: [ProcessIdentifier] = []
        var succeeds = true

        func activate(_ process: ProcessIdentifier) -> Bool {
            raised.append(process)
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
            snapshot: { pids.map(self.application) },
            activate: { activator.activate($0) }
        )
    }

    @Test("a session opens over the snapshot ordered by recent use")
    func opensOverOrderedSnapshot() {
        let coordinator = coordinator([1, 2, 3], order: MRUOrder(seed: [3, 2, 1].map(ProcessIdentifier.init)))
        #expect(coordinator.handle(.activate(.forward)) == .opened)
        #expect(coordinator.session?.applications.map(\.pid.rawValue) == [3, 2, 1])
        #expect(coordinator.session?.selection == 1)
    }

    @Test("an activation recorded during a session reorders only the next one")
    func activationAppliesToTheNextSession() {
        let coordinator = coordinator([1, 2])
        _ = coordinator.handle(.activate(.forward))
        coordinator.recordActivation(of: ProcessIdentifier(rawValue: 2))
        #expect(coordinator.session?.applications.map(\.pid.rawValue) == [1, 2])
        _ = coordinator.handle(.commit)
        _ = coordinator.handle(.activate(.forward))
        #expect(coordinator.session?.applications.map(\.pid.rawValue) == [2, 1])
    }

    @Test("the session is open only between activation and commit")
    func reportsSessionState() {
        let coordinator = coordinator([1, 2, 3])
        #expect(coordinator.isSessionOpen == false)
        _ = coordinator.handle(.activate(.forward))
        #expect(coordinator.isSessionOpen)
        #expect(coordinator.handle(.step(.forward)) == .moved)
        #expect(coordinator.handle(.commit) == .committed(ProcessIdentifier(rawValue: 3)))
        #expect(coordinator.isSessionOpen == false)
    }

    @Test("cancelling ends the session without choosing anything")
    func cancelEndsSession() {
        let coordinator = coordinator([1, 2])
        _ = coordinator.handle(.activate(.forward))
        #expect(coordinator.handle(.cancel) == .cancelled)
        #expect(coordinator.isSessionOpen == false)
    }

    @Test("committing raises the selected application once")
    func commitRaisesSelection() {
        let activator = ActivationSpy()
        let coordinator = coordinator([1, 2, 3], activator: activator)
        _ = coordinator.handle(.activate(.forward))
        _ = coordinator.handle(.step(.forward))
        #expect(coordinator.handle(.commit) == .committed(ProcessIdentifier(rawValue: 3)))
        #expect(activator.raised == [ProcessIdentifier(rawValue: 3)])
    }

    @Test("a commit the system refuses reports a failed activation")
    func failedActivationIsReported() {
        let activator = ActivationSpy()
        activator.succeeds = false
        let coordinator = coordinator([1, 2], activator: activator)
        _ = coordinator.handle(.activate(.forward))
        #expect(coordinator.handle(.commit) == .activationFailed(ProcessIdentifier(rawValue: 2)))
        #expect(coordinator.isSessionOpen == false)
    }

    @Test("nothing but a commit raises an application")
    func onlyCommitRaises() {
        let activator = ActivationSpy()
        let coordinator = coordinator([1, 2], activator: activator)
        #expect(coordinator.handle(.commit) == .ignored)
        _ = coordinator.handle(.activate(.forward))
        _ = coordinator.handle(.step(.forward))
        _ = coordinator.handle(.cancel)
        #expect(activator.raised.isEmpty)
    }
}
