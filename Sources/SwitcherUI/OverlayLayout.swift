import CoreGraphics

/// Geometry of the ribbon, in a top-left origin space: slot `y` grows downwards.
public struct OverlayLayout: Sendable, Equatable {
    public static let empty = OverlayLayout(size: .zero, iconSide: 0, visible: 0, slots: [])

    public let size: CGSize
    public let iconSide: CGFloat
    /// How many slots the panel shows at once; the rest are reached by scrolling.
    public let visible: Int
    /// One rect per application, holding the icon; the name is drawn under it. Slots beyond
    /// the visible window sit past the panel's trailing edge until the ribbon scrolls to them.
    public let slots: [CGRect]

    public var step: CGFloat { slots.count > 1 ? slots[1].minX - slots[0].minX : 0 }

    public static func compute(
        count: Int,
        screen: CGSize,
        metrics: OverlayMetrics = OverlayMetrics()
    ) -> OverlayLayout {
        guard count > 0, screen.width > 0, screen.height > 0 else { return .empty }
        let visible = metrics.visible(count: count)
        let icon = fittingIcon(
            count: visible,
            widest: (screen.width * metrics.widestShare).rounded(.down),
            metrics: metrics
        )
        let padding = metrics.padding(icon: icon)
        let size = CGSize(
            width: metrics.ribbonWidth(count: visible, icon: icon),
            height: metrics.slotHeight(icon: icon) + padding * 2
        )
        let step = icon + metrics.gap(icon: icon)
        return OverlayLayout(
            size: size,
            iconSide: icon,
            visible: visible,
            slots: (0..<count).map { index in
                CGRect(
                    x: padding + CGFloat(index) * step,
                    y: padding,
                    width: icon,
                    height: metrics.slotHeight(icon: icon)
                )
            }
        )
    }

    /// The largest icon whose row — gaps and paddings included, all of them shares of the
    /// icon — still fits the width budget. The row never wraps: like the system switcher,
    /// a crowded Space shrinks its icons instead of growing a second line.
    private static func fittingIcon(
        count: Int,
        widest: CGFloat,
        metrics: OverlayMetrics
    ) -> CGFloat {
        let spans = CGFloat(count) + CGFloat(count - 1) * metrics.gapShare + metrics.paddingShare * 2
        var icon = min(metrics.largestIcon, (widest / spans).rounded(.down))
        while icon > metrics.tiniestIcon, metrics.ribbonWidth(count: count, icon: icon) > widest {
            icon -= 1
        }
        return max(metrics.tiniestIcon, icon)
    }
}
