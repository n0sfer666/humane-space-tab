public struct SwitcherMachine: Sendable {
    public private(set) var session: SwitcherSession?

    public init() {}

    public var isSessionOpen: Bool {
        session != nil
    }

    public mutating func open(
        _ entries: [SwitcherEntry],
        _ direction: SelectionDirection,
        scope: SwitcherScope = .applications
    ) -> SwitcherEffect {
        guard session == nil,
            let opened = SwitcherSession(entries: entries, direction: direction, scope: scope)
        else { return .ignored }
        session = opened
        return .opened
    }

    public mutating func step(_ direction: SelectionDirection) -> SwitcherEffect {
        guard var current = session else { return .ignored }
        let previous = current.selection
        current.step(direction)
        session = current
        return current.selection == previous ? .ignored : .moved
    }

    public mutating func select(_ index: Int) -> SwitcherEffect {
        guard var current = session, current.entries.indices.contains(index), current.selection != index else {
            return .ignored
        }
        current.select(index)
        session = current
        return .moved
    }

    public mutating func cancel() -> SwitcherEffect {
        guard session != nil else { return .ignored }
        session = nil
        return .cancelled
    }

    /// An empty session has nothing to raise, so its commit is a close and not an
    /// activation (S18).
    public mutating func commit() -> SwitcherEffect {
        guard let current = session else { return .ignored }
        session = nil
        guard let target = current.selected?.target else { return .cancelled }
        return .committed(target)
    }
}
