public enum HotkeyDecision: Hashable, Sendable {
    case passThrough
    case consume
    case command(HotkeyCommand)
}
