import SwitcherCore
import SystemPorts

@MainActor
public struct PreferredSpaceMembership {
    private let preference: any SpaceLayerPreference
    private let privateLayer: any SpaceMembershipSource
    private let publicLayer: any SpaceMembershipSource
    private let log: any LogSink

    public init(
        preference: any SpaceLayerPreference,
        privateLayer: any SpaceMembershipSource,
        publicLayer: any SpaceMembershipSource,
        log: any LogSink
    ) {
        self.preference = preference
        self.privateLayer = privateLayer
        self.publicLayer = publicLayer
        self.log = log
    }

    public func membership(among candidates: [WindowInfo]) -> SpaceMembership {
        if preference.prefersPrivateLayer {
            if let windows = privateLayer.windowsOnCurrentSpace(among: candidates) {
                return SpaceMembership(layer: privateLayer.layer, windows: windows)
            }
            log.record(.privateSpaceLayerUnavailable)
        }
        return SpaceMembership(
            layer: publicLayer.layer,
            windows: publicLayer.windowsOnCurrentSpace(among: candidates) ?? []
        )
    }
}
