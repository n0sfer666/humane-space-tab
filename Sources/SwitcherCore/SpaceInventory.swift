public struct SpaceInventory: Sendable, Equatable {
    public let applications: [SwitchableApplication]
    public let windowsOnCurrentSpace: Set<WindowIdentifier>
    public let layer: SpaceMembershipLayer

    public init(
        applications: [SwitchableApplication],
        windowsOnCurrentSpace: Set<WindowIdentifier> = [],
        layer: SpaceMembershipLayer
    ) {
        self.applications = applications
        self.windowsOnCurrentSpace = windowsOnCurrentSpace
        self.layer = layer
    }
}
