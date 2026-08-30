public enum HotkeyCommand: Hashable, Sendable {
    case activate(SelectionDirection)
    case step(SelectionDirection)
    case cancel
    case commit
}
