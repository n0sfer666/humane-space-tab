@MainActor
public final class SwitcherCoordinator {
    private let snapshot: @MainActor () -> SpaceInventory
    private let expand: @MainActor ([SwitchableApplication], Set<WindowIdentifier>) -> [SwitcherEntry]
    private let activate: @MainActor (SwitcherTarget) -> Bool
    private var machine = SwitcherMachine()
    private var order: MRUOrder

    public init(
        order: MRUOrder = MRUOrder(),
        snapshot: @escaping @MainActor () -> SpaceInventory,
        expand: @escaping @MainActor ([SwitchableApplication], Set<WindowIdentifier>) -> [SwitcherEntry] =
            SwitcherEntry.applications,
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

    /// The window set travels with the applications because the inventory computed it in the
    /// same pass: asking the system for it again would be a second Space attribution inside
    /// the tap callback, for an answer that is already in hand.
    private func open(_ direction: SelectionDirection) -> SwitcherEffect {
        let inventory = snapshot()
        return machine.open(expand(order.ordered(inventory.applications), inventory.windowsOnCurrentSpace), direction)
    }

    public func handle(_ command: HotkeyCommand) -> SwitcherEffect {
        switch command {
        case .activate(let direction): open(direction)
        case .step(let direction): machine.step(direction)
        case .cancel: machine.cancel()
        case .commit: raise(machine.commit())
        }
    }
}
