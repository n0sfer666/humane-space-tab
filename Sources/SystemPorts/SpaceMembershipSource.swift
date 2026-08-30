import SwitcherCore

@MainActor
public protocol SpaceMembershipSource: Sendable {
    var layer: SpaceMembershipLayer { get }

    /// The candidates that live on the current Space, or `nil` when this layer cannot answer.
    func windowsOnCurrentSpace(among candidates: [WindowInfo]) -> Set<WindowIdentifier>?
}
