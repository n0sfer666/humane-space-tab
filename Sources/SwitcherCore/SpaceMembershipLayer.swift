public enum SpaceMembershipLayer: String, CaseIterable, Sendable {
    case onScreen
    case skyLight

    public var label: String {
        switch self {
        case .onScreen: "public (on-screen windows)"
        case .skyLight: "private (SkyLight)"
        }
    }
}
