import AppKit
import SwitcherCore

/// The panel's material. macOS 26 draws its own switcher in Liquid Glass, so where the system
/// has that material the ribbon is made of it too; older systems keep the HUD blur, which is
/// what they render their own panels with. A profile may ask for neither and take a plain
/// panel instead — transparent, or the window background colour.
@MainActor
enum OverlayBackdrop {
    static func make(cornerRadius: CGFloat, background: BackgroundStyle, content: NSView) -> NSView {
        content.wantsLayer = true
        content.autoresizingMask = [.width, .height]
        switch background {
        case .glass(let scrim): return blurred(cornerRadius: cornerRadius, scrim: scrim, content: content)
        case .transparent(let opacity):
            let plain = plate(cornerRadius: cornerRadius, colour: .clear, content: content)
            plain.alphaValue = opacity
            return plain
        case .solid(let opacity):
            return plate(
                cornerRadius: cornerRadius,
                colour: NSColor.windowBackgroundColor.withAlphaComponent(CGFloat(opacity)),
                content: content
            )
        }
    }

    private static func blurred(cornerRadius: CGFloat, scrim: Double, content: NSView) -> NSView {
        if #available(macOS 26.0, *) {
            let glass = NSGlassEffectView()
            glass.cornerRadius = cornerRadius
            glass.style = .regular
            glass.contentView = scrimmed(content, cornerRadius: cornerRadius, scrim: scrim)
            return glass
        }
        return hud(cornerRadius: cornerRadius, scrim: scrim, content: content)
    }

    /// Frosted glass still carries the brightness of what is behind it, and the ribbon's
    /// labels are light: over a white window they would wash out. `tintColor` does not dim the
    /// material, so the scrim is painted here — dark enough to keep the labels readable, light
    /// enough to leave the translucency that made the material worth using.
    ///
    /// It is painted on a view of its own rather than on the ribbon, because a step slides the
    /// ribbon's layer: a scrim travelling with it would drag a lighter stripe of bare glass
    /// across the edge of the panel for the length of the animation.
    private static func scrimmed(_ content: NSView, cornerRadius: CGFloat, scrim: Double) -> NSView {
        plate(cornerRadius: cornerRadius, colour: .black.withAlphaComponent(CGFloat(scrim)), content: content)
    }

    private static func plate(cornerRadius: CGFloat, colour: NSColor, content: NSView) -> NSView {
        let plate = NSView()
        plate.wantsLayer = true
        plate.autoresizingMask = [.width, .height]
        plate.layer?.backgroundColor = colour.cgColor
        plate.layer?.cornerRadius = cornerRadius
        plate.layer?.masksToBounds = true
        plate.addSubview(content)
        return plate
    }

    private static func hud(cornerRadius: CGFloat, scrim: Double, content: NSView) -> NSView {
        let effect = NSVisualEffectView()
        effect.material = .hudWindow
        effect.blendingMode = .behindWindow
        effect.state = .active
        effect.wantsLayer = true
        effect.layer?.cornerRadius = cornerRadius
        effect.layer?.borderWidth = 1
        effect.layer?.borderColor = NSColor.white.withAlphaComponent(0.12).cgColor
        effect.layer?.masksToBounds = true
        effect.autoresizingMask = [.width, .height]
        effect.addSubview(scrimmed(content, cornerRadius: cornerRadius, scrim: scrim))
        return effect
    }
}
