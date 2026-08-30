@MainActor
public final class SwitcherCoordinator {
    private let snapshot: @MainActor () -> [SwitchableApplication]
    private var machine = SwitcherMachine()
    private var order: MRUOrder

    public init(
        order: MRUOrder = MRUOrder(),
        snapshot: @escaping @MainActor () -> [SwitchableApplication]
    ) {
        self.order = order
        self.snapshot = snapshot
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

    public func handle(_ command: HotkeyCommand) -> SwitcherEffect {
        switch command {
        case .activate(let direction): machine.open(order.ordered(snapshot()), direction)
        case .step(let direction): machine.step(direction)
        case .cancel: machine.cancel()
        case .commit: machine.commit()
        }
    }
}
