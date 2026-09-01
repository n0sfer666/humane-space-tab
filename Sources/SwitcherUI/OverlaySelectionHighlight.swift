import AppKit

/// The rounded plate macOS draws behind the selected application in its own switcher. Only
/// the presets that ask for it get one — the others tell the selection apart by size, by
/// dimming the rest, or by a frame, and a plate under those would say the same thing twice.
@MainActor
enum OverlaySelectionHighlight {
    static func draw(behind icon: CGRect, metrics: OverlayMetrics, selected: Bool) {
        guard selected, metrics.selection.highlightsSelection else { return }
        let plate = icon.insetBy(dx: -metrics.padding(icon: icon.width) / 2, dy: -metrics.padding(icon: icon.width) / 2)
        let radius = (plate.width * 0.22).rounded()
        NSColor.white.withAlphaComponent(0.22).setFill()
        NSBezierPath(roundedRect: plate, xRadius: radius, yRadius: radius).fill()
    }
}
