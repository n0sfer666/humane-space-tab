public struct SpaceInventory: Sendable, Equatable {
    public let applications: [SwitchableApplication]
    public let layer: SpaceMembershipLayer

    public init(applications: [SwitchableApplication], layer: SpaceMembershipLayer) {
        self.applications = applications
        self.layer = layer
    }
}
