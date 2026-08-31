public enum HotkeyCommand: Hashable, Sendable {
    case activate(SelectionDirection, SwitcherScope)
    case step(SelectionDirection)
    case cancel
    case commit
}
