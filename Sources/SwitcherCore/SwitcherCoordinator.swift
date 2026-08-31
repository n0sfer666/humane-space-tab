@MainActor
public final class SwitcherCoordinator {
    private let snapshot: @MainActor () -> SpaceInventory
    private let expand: @MainActor ([SwitchableApplication], Set<WindowIdentifier>) -> [SwitcherEntry]
    private let cycle: @MainActor ([SwitchableApplication], Set<WindowIdentifier>) -> [SwitcherEntry]
    private let activate: @MainActor (SwitcherTarget) -> Bool
    private var machine = SwitcherMachine()
    private var order: MRUOrder

    public init(
        order: MRUOrder = MRUOrder(),
        snapshot: @escaping @MainActor () -> SpaceInventory,
        expand: @escaping @MainActor ([SwitchableApplication], Set<WindowIdentifier>) -> [SwitcherEntry] =
            SwitcherEntry.applications,
        cycle: @escaping @MainActor ([SwitchableApplication], Set<WindowIdentifier>) -> [SwitcherEntry] =
            SwitcherEntry.frontWindows,
        activate: @escaping @MainActor (SwitcherTarget) -> Bool
    ) {
        self.order = order
        self.snapshot = snapshot
        self.expand = expand
        self.cycle = cycle
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

    /// One window is no choice at all, so a window session with fewer than two entries is
    /// not opened: S12 gives the key back to the application underneath instead.
    ///
    /// The window set travels with the applications because the inventory computed it in the
    /// same pass: asking the system for it again would be a second Space attribution inside
    /// the tap callback, for an answer that is already in hand.
    private func open(_ direction: SelectionDirection, _ scope: SwitcherScope) -> SwitcherEffect {
        let inventory = snapshot()
        let applications = order.ordered(inventory.applications)
        let windows = inventory.windowsOnCurrentSpace
        switch scope {
        case .applications:
            return machine.open(expand(applications, windows), direction, scope: scope)
        case .frontWindows:
            let entries = cycle(applications, windows)
            guard entries.count > 1 else { return .ignored }
            return machine.open(entries, direction, scope: scope)
        }
    }

    /// The pointer names the entry it is over, so it moves the selection by index while the
    /// keyboard moves it by direction; both end in the same session.
    public func select(_ index: Int) -> SwitcherEffect {
        machine.select(index)
    }

    public func handle(_ command: HotkeyCommand) -> SwitcherEffect {
        switch command {
        case .activate(let direction, let scope): open(direction, scope)
        case .step(let direction): machine.step(direction)
        case .cancel: machine.cancel()
        case .commit: raise(machine.commit())
        }
    }
}
