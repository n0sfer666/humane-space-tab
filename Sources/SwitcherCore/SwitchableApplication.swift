public struct SwitchableApplication: Sendable, Equatable {
    public let pid: ProcessIdentifier
    public let bundleIdentifier: String?
    public let name: String
    public let isActive: Bool
    public let windows: [ApplicationWindow]

    public init(
        pid: ProcessIdentifier,
        bundleIdentifier: String?,
        name: String,
        isActive: Bool,
        windows: [ApplicationWindow]
    ) {
        self.pid = pid
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.isActive = isActive
        self.windows = windows
    }

    public func with(windows: [ApplicationWindow]) -> SwitchableApplication {
        SwitchableApplication(
            pid: pid,
            bundleIdentifier: bundleIdentifier,
            name: name,
            isActive: isActive,
            windows: windows
        )
    }
}
