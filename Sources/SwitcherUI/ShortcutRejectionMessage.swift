import SwitcherCore

enum ShortcutRejectionMessage {
    static func text(for rejection: ShortcutRejection) -> String {
        switch rejection {
        case .noModifier:
            return "Add ⌘, ⌥ or ⌃ — the switcher stays open while a modifier is held."
        case .containsShift:
            return "Shift is reserved: it reverses the direction of whatever you choose."
        case .escape:
            return "Escape closes the switcher and force-quits a stuck app. Pick another key."
        case .reserved:
            return "That shortcut quits or closes an app. Pick another one."
        case .modifierKey:
            return "That key only ever modifies another one. Pick a key to tap while holding it."
        case .taken:
            return "That is already the other shortcut. Pick a different one."
        }
    }
}
