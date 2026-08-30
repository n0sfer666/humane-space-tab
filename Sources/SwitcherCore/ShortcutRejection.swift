public enum ShortcutRejection: Equatable, Sendable {
    case noModifier
    case containsShift
    case escape
    case reserved
    case modifierKey
}
