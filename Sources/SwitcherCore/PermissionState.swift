public enum PermissionState: Hashable, Sendable {
    case blocked(canAsk: Bool)
    case observing
    case intercepting

    public init(isTrusted: Bool, tap: HotkeyTapMode?) {
        switch tap {
        case .intercept: self = .intercepting
        case .observe: self = .observing
        case nil: self = .blocked(canAsk: !isTrusted)
        }
    }

    public var needsAttention: Bool {
        self != .intercepting
    }

    public var offersGrant: Bool {
        self == .blocked(canAsk: true)
    }

    /// Every state the user has to act on says what is wrong in one line; the working state
    /// says nothing, because a menu that explains success is a menu nobody reads.
    public var detail: String? {
        switch self {
        case .blocked(canAsk: true):
            "Accessibility is off, so Cmd+Tab still belongs to macOS."
        case .blocked(canAsk: false):
            "macOS refused the keyboard tap. Quitting and reopening the app is the only cure."
        case .observing:
            "The switcher can see Cmd+Tab but not take it over."
        case .intercepting:
            nil
        }
    }
}
