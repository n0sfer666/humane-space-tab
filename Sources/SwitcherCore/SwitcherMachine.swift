public struct SwitcherMachine: Sendable {
    public private(set) var session: SwitcherSession?

    public init() {}

    public var isSessionOpen: Bool {
        session != nil
    }

    public mutating func open(
        _ applications: [SwitchableApplication],
        _ direction: SelectionDirection
    ) -> SwitcherEffect {
        guard session == nil,
            let opened = SwitcherSession(applications: applications, direction: direction)
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

    public mutating func cancel() -> SwitcherEffect {
        guard session != nil else { return .ignored }
        session = nil
        return .cancelled
    }

    public mutating func commit() -> SwitcherEffect {
        guard let current = session else { return .ignored }
        session = nil
        return .committed(current.selected.pid)
    }
}
