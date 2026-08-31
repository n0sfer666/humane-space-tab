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
            glass.contentView = content
            return glass
        }
        return hud(cornerRadius: cornerRadius, content: content)
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
