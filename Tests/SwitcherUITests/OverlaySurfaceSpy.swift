import SwitcherUI

@MainActor
final class OverlaySurfaceSpy: OverlaySurface {
    private(set) var shown: [OverlayModel] = []
    private(set) var updated: [OverlayModel] = []
    private(set) var hides = 0

    func show(_ model: OverlayModel) { shown.append(model) }
    func update(_ model: OverlayModel) { updated.append(model) }
    func hide() { hides += 1 }
}
