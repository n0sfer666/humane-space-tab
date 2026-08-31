import CoreGraphics

/// Which tile a point lands on, in the ribbon's own coordinates. Each slot claims its icon
/// plus half the gap on either side, so the row has no dead stripes between tiles, while the
/// padding at the panel's ends belongs to no tile at all.
public enum RibbonHitTest {
    public static func slot(at point: CGPoint, layout: OverlayLayout, offset: Int) -> Int? {
        guard !layout.slots.isEmpty,
            CGRect(origin: .zero, size: layout.size).contains(point)
        else { return nil }
        let scrolled = point.x + CGFloat(offset) * layout.step
        let reach = (layout.step - layout.iconSide) / 2
        return layout.slots.firstIndex { $0.minX - reach <= scrolled && scrolled < $0.maxX + reach }
    }
}
