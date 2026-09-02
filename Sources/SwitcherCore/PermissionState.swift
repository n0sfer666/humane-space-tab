public enum PermissionState: Hashable, Sendable {
    case blocked(canAsk: Bool)
    case deaf
    case secured(by: String?)
    case observing
    case intercepting

    /// `deaf` outranks `observing`: a tap that receives no key presses cannot observe them
    /// either, and reporting the milder problem would send the user to the wrong list.
    /// `secured` outranks both working states and `observing`, because secure input is what
    /// causes a tap to be handed observation in the first place: a session that hands the
    /// app no key presses is not intercepting anything, whatever its mask says.
    public init(
        isTrusted: Bool,
        tap: HotkeyTapMode?,
        deliversKeys: Bool,
        secureInput: SecureInputHolder? = nil
    ) {
        switch (tap, deliversKeys) {
        case (nil, _): self = .blocked(canAsk: !isTrusted)
        case (.some, false): self = .deaf
        case (.some(let mode), true):
            if let secureInput {
                self = .secured(by: secureInput.name)
            } else {
                self = mode == .intercept ? .intercepting : .observing
            }
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
