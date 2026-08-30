public struct SpaceMembership: Sendable, Equatable {
    public let layer: SpaceMembershipLayer
    public let windows: Set<WindowIdentifier>

    public init(layer: SpaceMembershipLayer, windows: Set<WindowIdentifier>) {
        self.layer = layer
        self.windows = windows
    }
}
