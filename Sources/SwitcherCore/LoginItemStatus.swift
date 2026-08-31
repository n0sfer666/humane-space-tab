public enum LoginItemStatus: Sendable {
    case enabled
    case notRegistered
    case requiresApproval

    /// Approval pending is not "off": macOS has accepted the registration and is only
    /// asking the user to confirm it once, and showing it off invites a second one.
    public var isOn: Bool {
        switch self {
        case .enabled, .requiresApproval: true
        case .notRegistered: false
        }
    }

    public var message: String? {
        switch self {
        case .enabled, .notRegistered: nil
        case .requiresApproval:
            "Waiting for approval in System Settings › General › Login Items."
        }
    }
}
