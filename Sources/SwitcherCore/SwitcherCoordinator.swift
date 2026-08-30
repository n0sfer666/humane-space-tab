@MainActor
public final class SwitcherCoordinator {
    private let snapshot: @MainActor () -> [SwitchableApplication]
    private let activate: @MainActor (ProcessIdentifier) -> Bool
    private var machine = SwitcherMachine()
    private var order: MRUOrder

    public init(
        order: MRUOrder = MRUOrder(),
        snapshot: @escaping @MainActor () -> [SwitchableApplication],
        activate: @escaping @MainActor (ProcessIdentifier) -> Bool
    ) {
        self.order = order
        self.snapshot = snapshot
        self.activate = activate
    }

    public var isSessionOpen: Bool {
        machine.isSessionOpen
    }

    public var session: SwitcherSession? {
        machine.session
    }

    public func recordActivation(of process: ProcessIdentifier) {
        order.record(process)
    }

    private func raise(_ effect: SwitcherEffect) -> SwitcherEffect {
        guard case .committed(let process) = effect else { return effect }
        return activate(process) ? effect : .activationFailed(process)
    }

    public func handle(_ command: HotkeyCommand) -> SwitcherEffect {
        switch command {
        case .activate(let direction): machine.open(order.ordered(snapshot()), direction)
        case .step(let direction): machine.step(direction)
        case .cancel: machine.cancel()
        case .commit: raise(machine.commit())
        }
    }
}
