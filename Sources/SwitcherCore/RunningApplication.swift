public struct RunningApplication: Sendable, Equatable {
    public let pid: ProcessIdentifier
    public let bundleIdentifier: String?
    public let name: String
    public let bundlePath: String?
    public let policy: ActivationPolicy
    public let isHidden: Bool
    public let isActive: Bool

    public init(
        pid: ProcessIdentifier,
        bundleIdentifier: String?,
        name: String,
        bundlePath: String?,
        policy: ActivationPolicy,
        isHidden: Bool,
        isActive: Bool
    ) {
        self.pid = pid
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.bundlePath = bundlePath
        self.policy = policy
        self.isHidden = isHidden
        self.isActive = isActive
    }
}
