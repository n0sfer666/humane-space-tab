import AppKit

/// The panel's material. macOS 26 draws its own switcher in Liquid Glass, so where the system
/// has that material the ribbon is made of it too; older systems keep the HUD blur, which is
/// what they render their own panels with.
@MainActor
enum OverlayBackdrop {
    static func make(cornerRadius: CGFloat, content: NSView) -> NSView {
        content.wantsLayer = true
        content.autoresizingMask = [.width, .height]
        if #available(macOS 26.0, *) {
            let glass = NSGlassEffectView()
            glass.cornerRadius = cornerRadius
            glass.style = .clear
            glass.contentView = scrimmed(content, cornerRadius: cornerRadius)
            return glass
        }
        return hud(cornerRadius: cornerRadius, content: content)
    }

    /// Clear glass takes the brightness of whatever is behind it, and the ribbon's labels are
    /// light: over a white window they would wash out. `tintColor` does not dim the material,
    /// so the scrim is painted here — dark enough to keep the labels readable, light enough to
    /// leave the translucency that made the material worth using.
    private static func scrimmed(_ content: NSView, cornerRadius: CGFloat) -> NSView {
        content.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.15).cgColor
        content.layer?.cornerRadius = cornerRadius
        content.layer?.masksToBounds = true
        return content
    }

    private static func hud(cornerRadius: CGFloat, content: NSView) -> NSView {
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
        effect.addSubview(content)
        return effect
    }
}
