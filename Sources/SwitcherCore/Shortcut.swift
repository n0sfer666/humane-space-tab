public struct Shortcut: Hashable, Sendable {
    public static let commandTab = Shortcut(key: .tab, modifiers: [.command])
    public static let commandGrave = Shortcut(key: .grave, modifiers: [.command])

    public let key: KeyCode
    public let modifiers: ModifierSet

    public init(key: KeyCode, modifiers: ModifierSet) {
        self.key = key
        self.modifiers = modifiers
    }

    func direction(for stroke: KeyStroke) -> SelectionDirection? {
        guard stroke.key == key else { return nil }
        if stroke.modifiers == modifiers { return .forward }
        guard !modifiers.contains(.shift), stroke.modifiers == modifiers.union(.shift) else { return nil }
        return .backward
    }

    func isHeld(in modifiers: ModifierSet) -> Bool {
        self.modifiers.isSubset(of: modifiers)
    }
}
