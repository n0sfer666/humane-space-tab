@MainActor
public final class SwitcherCoordinator {
    private let snapshot: @MainActor () -> [SwitchableApplication]
    private let expand: @MainActor ([SwitchableApplication]) -> [SwitcherEntry]
    private let activate: @MainActor (SwitcherTarget) -> Bool
    private var machine = SwitcherMachine()
    private var order: MRUOrder

    public init(
        order: MRUOrder = MRUOrder(),
        snapshot: @escaping @MainActor () -> [SwitchableApplication],
        expand: @escaping @MainActor ([SwitchableApplication]) -> [SwitcherEntry] = {
            $0.map { SwitcherEntry(application: $0) }
        },
        activate: @escaping @MainActor (SwitcherTarget) -> Bool
    ) {
        self.order = order
        self.snapshot = snapshot
        self.expand = expand
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
        guard case .committed(let target) = effect else { return effect }
        return activate(target) ? effect : .activationFailed(target)
    }

    public func handle(_ command: HotkeyCommand) -> SwitcherEffect {
        switch command {
        case .activate(let direction): machine.open(expand(order.ordered(snapshot())), direction)
        case .step(let direction): machine.step(direction)
        case .cancel: machine.cancel()
        case .commit: raise(machine.commit())
        }
    }
}
