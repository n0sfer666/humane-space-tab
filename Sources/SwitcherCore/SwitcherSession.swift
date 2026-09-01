public struct SwitcherSession: Equatable, Sendable {
    public let entries: [SwitcherEntry]
    /// Which shortcut opened it, so the release of a held modifier is read against that
    /// shortcut and not against the other one (S12).
    public let scope: SwitcherScope
    public private(set) var selection: Int

    /// A Space with nothing open on it still gets an answer (S18), so an application
    /// session opens on an empty list and says so. A window session does not: one window is
    /// no choice at all, and S12 gives the key back instead.
    init?(entries: [SwitcherEntry], direction: SelectionDirection, scope: SwitcherScope = .applications) {
        guard !entries.isEmpty || scope == .applications else { return nil }
        self.entries = entries
        self.scope = scope
        selection = 0
        step(direction)
    }

    public var isEmpty: Bool {
        entries.isEmpty
    }

    public var selected: SwitcherEntry? {
        entries.indices.contains(selection) ? entries[selection] : nil
    }

    mutating func select(_ index: Int) {
        selection = index
    }

    mutating func step(_ direction: SelectionDirection) {
        let count = entries.count
        guard count > 0 else { return }
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
