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

}
