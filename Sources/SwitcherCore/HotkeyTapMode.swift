public enum HotkeyTapMode: Hashable, Sendable {
    case observe
    case intercept

    public func swallows(_ decision: HotkeyDecision) -> Bool {
        guard self == .intercept else { return false }
        return decision != .passThrough
    }
}
