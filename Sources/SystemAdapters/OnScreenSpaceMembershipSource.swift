import SwitcherCore
import SystemPorts

@MainActor
public struct OnScreenSpaceMembershipSource: SpaceMembershipSource {
    public let layer = SpaceMembershipLayer.onScreen

    public init() {}

    public func windowsOnCurrentSpace(among candidates: [WindowInfo]) -> Set<WindowIdentifier>? {
        Set(candidates.filter(\.isOnScreen).map(\.id))
    }
}
