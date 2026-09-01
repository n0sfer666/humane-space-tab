import SwitcherCore

enum ShortcutRejectionMessage {
    @MainActor
    static func text(for rejection: ShortcutRejection) -> String {
        Localised.text(key(for: rejection))
    }

    private static func key(for rejection: ShortcutRejection) -> UIText {
        switch rejection {
        case .noModifier: .rejectNoModifier
        case .containsShift: .rejectContainsShift
        case .escape: .rejectEscape
        case .reserved: .rejectReserved
        case .modifierKey: .rejectModifierKey
        case .taken: .rejectTaken
        }
    }
}
