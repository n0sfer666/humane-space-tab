public struct SwitcherSession: Equatable, Sendable {
    public let entries: [SwitcherEntry]
    /// Which shortcut opened it, so the release of a held modifier is read against that
    /// shortcut and not against the other one (S12).
    public let scope: SwitcherScope
    public private(set) var selection: Int

    init?(entries: [SwitcherEntry], direction: SelectionDirection, scope: SwitcherScope = .applications) {
        guard !entries.isEmpty else { return nil }
        self.entries = entries
        self.scope = scope
        selection = 0
        step(direction)
    }

    public var selected: SwitcherEntry {
        entries[selection]
    }

    mutating func select(_ index: Int) {
        selection = index
    }

    mutating func step(_ direction: SelectionDirection) {
        let count = entries.count
        selection = (selection + direction.offset + count) % count
    }
}

extension SelectionDirection {
    fileprivate var offset: Int {
        switch self {
        case .forward: 1
        case .backward: -1
        }
    }
}
