public enum PermissionState: Hashable, Sendable {
    case blocked(canAsk: Bool)
    case deaf
    case observing
    case intercepting

    /// `deaf` outranks `observing`: a tap that receives no key presses cannot observe them
    /// either, and reporting the milder problem would send the user to the wrong list.
    public init(isTrusted: Bool, tap: HotkeyTapMode?, deliversKeys: Bool) {
        switch (tap, deliversKeys) {
        case (nil, _): self = .blocked(canAsk: !isTrusted)
        case (.some, false): self = .deaf
        case (.some(.intercept), true): self = .intercepting
        case (.some(.observe), true): self = .observing
        }
    }

    public var needsAttention: Bool {
        self != .intercepting
    }

    public var offersGrant: Bool {
        self == .blocked(canAsk: true)
    }

    public var offersInputMonitoring: Bool {
        self == .deaf
    }

    /// Every state the user has to act on says what is wrong in one line; the working state
    /// says nothing, because a menu that explains success is a menu nobody reads.
    public var detail: String? {
        switch self {
        case .blocked(canAsk: true):
            "Accessibility is off, so Cmd+Tab still belongs to macOS."
        case .blocked(canAsk: false):
            "macOS refused the keyboard tap. Quitting and reopening the app is the only cure."
        case .deaf:
            "macOS is withholding key presses. Remove this app from Input Monitoring."
        case .observing:
            "The switcher can see Cmd+Tab but not take it over."
        case .intercepting:
            nil
        }
    }
}
