import SwitcherCore
import SystemPorts

@MainActor
struct ShortcutFormatter {
    private let naming: any KeyNaming

    init(naming: any KeyNaming) {
        self.naming = naming
    }

    func label(for shortcut: Shortcut) -> String {
        Self.glyphs(for: shortcut.modifiers) + key(shortcut.key)
    }

    private func key(_ key: KeyCode) -> String {
        key.glyph ?? naming.name(for: key) ?? Localised.text(.shortcutUnnamedKey, Int(key.rawValue))
    }

    /// The system prints modifiers in this order regardless of how they were pressed, and
    /// a shortcut that reads differently from every other one on the machine looks wrong
    /// before it looks configurable.
    private static func glyphs(for modifiers: ModifierSet) -> String {
        let ordered: [(ModifierSet, String)] = [
            (.control, "⌃"), (.option, "⌥"), (.shift, "⇧"), (.command, "⌘"),
        ]
        return ordered.filter { modifiers.contains($0.0) }.map(\.1).joined()
    }
}
