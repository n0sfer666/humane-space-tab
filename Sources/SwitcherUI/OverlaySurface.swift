@MainActor
public protocol OverlaySurface: AnyObject {
    /// Puts the ribbon on screen for the first time in this session.
    func show(_ model: OverlayModel)
    /// Redraws an already visible ribbon.
    func update(_ model: OverlayModel)
    /// Takes the ribbon off screen.
    func hide()
}
