import AppKit
import SwitcherCore

/// The outline a profile may ask for around its icons. Which icons wear it is the preset's
/// business: the framed preset gives one to the selection alone, because that is what tells
/// it apart there; every other preset frames the row, and the frame is decoration.
enum OverlayIconFrame {
    /// The frame as it is actually drawn, or nothing where no frame belongs. The framed
    /// preset is the one place a frame appears without being asked for by width: it is how
    /// that preset shows the selection, so a hairline stands in for a width of zero.
    static func drawn(_ style: FrameStyle, selection: SelectionPreset, selected: Bool) -> FrameStyle? {
        guard selected || !selection.framesSelection else { return nil }
        if selection.framesSelection, selected, !style.isDrawn { return style.with(width: FrameStyle.hairline) }
        return style.isDrawn ? style : nil
    }

    static func draw(around rect: CGRect, style: FrameStyle, icon: CGFloat, selected: Bool, metrics: OverlayMetrics) {
        guard let style = drawn(style, selection: metrics.selection, selected: selected) else { return }
        let padding = CGFloat(style.padding(icon: Double(icon)))
        let outline = rect.insetBy(dx: -padding, dy: -padding).insetBy(
            dx: CGFloat(style.width) / 2,
            dy: CGFloat(style.width) / 2
        )
        let radius = CGFloat(style.radius)
        let path = NSBezierPath(roundedRect: outline, xRadius: radius, yRadius: radius)
        path.lineWidth = CGFloat(style.width)
        NSColor.labelColor.withAlphaComponent(selected ? 0.85 : 0.35 * metrics.dimmed).setStroke()
        path.stroke()
    }
}
