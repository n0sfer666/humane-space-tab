import SwitcherCore
import SystemPorts

@MainActor
struct SpaceMembershipStub: SpaceMembershipSource {
    let layer: SpaceMembershipLayer
    let answer: Set<WindowIdentifier>?

    func windowsOnCurrentSpace(among candidates: [WindowInfo]) -> Set<WindowIdentifier>? {
        answer
    }
}
