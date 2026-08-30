import SwitcherCore
import SystemPorts

@MainActor
public struct SkyLightSpaceMembershipSource: SpaceMembershipSource {
    public let layer = SpaceMembershipLayer.skyLight
    private let shim: SkyLightShim?

    public init() {
        shim = SkyLightShim()
    }

    public func windowsOnCurrentSpace(among candidates: [WindowInfo]) -> Set<WindowIdentifier>? {
        guard let shim, let active = shim.activeSpaces() else { return nil }
        var members: Set<WindowIdentifier> = []
        var answered = false
        for candidate in candidates {
            guard let spaces = shim.spaces(of: candidate.id.rawValue) else { continue }
            answered = true
            if !spaces.isDisjoint(with: active) { members.insert(candidate.id) }
        }
        guard answered || candidates.isEmpty else { return nil }
        return members
    }
}
