public struct ShortcutSet: Hashable, Sendable {
    public static let standard = ShortcutSet()

    public let applications: Shortcut
    public let frontWindows: Shortcut

    public init(applications: Shortcut = .commandTab, frontWindows: Shortcut = .commandGrave) {
        self.applications = applications
        self.frontWindows = frontWindows
    }

    public func shortcut(for scope: SwitcherScope) -> Shortcut {
        switch scope {
        case .applications: applications
        case .frontWindows: frontWindows
        }
    }

    /// The applications shortcut is tried first, so a pair that collides — reachable only
    /// by hand-editing the store, since the recorder refuses a duplicate — resolves to the
    /// older gesture rather than to neither.
    func match(_ stroke: KeyStroke) -> (scope: SwitcherScope, direction: SelectionDirection)? {
        if let direction = applications.direction(for: stroke) { return (.applications, direction) }
        if let direction = frontWindows.direction(for: stroke) { return (.frontWindows, direction) }
        return nil
    }
}
