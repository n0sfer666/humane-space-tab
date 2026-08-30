import CoreGraphics

/// Geometry of the ribbon, in a top-left origin space: slot `y` grows downwards.
public struct OverlayLayout: Sendable, Equatable {
    public static let empty = OverlayLayout(size: .zero, iconSide: 0, columns: 0, slots: [])

    public let size: CGSize
    public let iconSide: CGFloat
    public let columns: Int
    /// One rect per application, each holding the icon area and the name underneath it.
    public let slots: [CGRect]

    public static func compute(
        count: Int,
        screen: CGSize,
        metrics: OverlayMetrics = OverlayMetrics()
    ) -> OverlayLayout {
        guard count > 0, screen.width > 0, screen.height > 0 else { return .empty }
        let widest = screen.width * metrics.widestShare - metrics.padding * 2
        let fit = fitting(
            count: count,
            widest: widest,
            tallest: screen.height * metrics.tallestShare - metrics.padding * 2,
            metrics: metrics
        )
        let icon = fit.icon
        let columns = fit.columns
        let gap = fillingGap(
            columns: columns,
            icon: icon,
            target: screen.width * metrics.targetShare - metrics.padding * 2,
            widest: widest,
            metrics: metrics
        )
        let width = (metrics.rowWidth(columns: columns, icon: icon, gap: gap) + metrics.padding * 2)
            .rounded()
        let height =
            (metrics.padding * 2
            + rowsHeight(count: count, columns: columns, icon: icon, metrics: metrics)).rounded()
        return OverlayLayout(
            size: CGSize(width: width, height: height),
            iconSide: icon,
            columns: columns,
            slots: slots(
                count: count,
                plan: SlotPlan(columns: columns, icon: icon, gap: gap, width: width, metrics: metrics)
            )
        )
    }

    /// The icon that fits the ribbon into both budgets: the width cap first, then the height cap,
    /// which only ever binds at counts no single Space reaches.
    private static func fitting(
        count: Int,
        widest: CGFloat,
        tallest: CGFloat,
        metrics: OverlayMetrics
    ) -> (icon: CGFloat, columns: Int) {
        var icon = fittingIcon(count: count, widest: widest, metrics: metrics)
        var columns = columnsPerRow(count: count, icon: icon, widest: widest, metrics: metrics)
        while icon > metrics.tiniestIcon {
            guard rowsHeight(count: count, columns: columns, icon: icon, metrics: metrics) > tallest
            else { break }
            icon = max(metrics.tiniestIcon, icon - 4)
            columns = columnsPerRow(count: count, icon: icon, widest: widest, metrics: metrics)
        }
        return (icon, columns)
    }

    private static func rowsHeight(
        count: Int,
        columns: Int,
        icon: CGFloat,
        metrics: OverlayMetrics
    ) -> CGFloat {
        let rows = CGFloat(Int((Double(count) / Double(max(1, columns))).rounded(.up)))
        return rows * metrics.rowHeight(icon: icon) + (rows - 1) * metrics.rowGap
    }

    private static func fittingIcon(count: Int, widest: CGFloat, metrics: OverlayMetrics) -> CGFloat {
        let available = widest - CGFloat(count - 1) * metrics.smallestGap
        guard available > 0 else { return metrics.smallestIcon }
        let side = (available / CGFloat(count) - metrics.tilePadding * 2) / metrics.selectedScale
        return min(metrics.largestIcon, max(metrics.smallestIcon, side.rounded(.down)))
    }

    private static func columnsPerRow(
        count: Int,
        icon: CGFloat,
        widest: CGFloat,
        metrics: OverlayMetrics
    ) -> Int {
        let slot = metrics.slotWidth(icon: icon)
        let fitting = Int((widest + metrics.smallestGap) / (slot + metrics.smallestGap))
        let perRow = max(1, min(count, fitting))
        guard perRow < count else { return count }
        let rows = Int((Double(count) / Double(perRow)).rounded(.up))
        return Int((Double(count) / Double(rows)).rounded(.up))
    }

    private static func fillingGap(
        columns: Int,
        icon: CGFloat,
        target: CGFloat,
        widest: CGFloat,
        metrics: OverlayMetrics
    ) -> CGFloat {
        guard columns > 1 else { return metrics.smallestGap }
        let slots = CGFloat(columns) * metrics.slotWidth(icon: icon)
        let missing = (target - slots) / CGFloat(columns - 1)
        let gap = min(metrics.largestGap, max(metrics.smallestGap, missing.rounded()))
        let overflow = (slots + CGFloat(columns - 1) * gap) - widest
        guard overflow > 0 else { return gap }
        return max(metrics.smallestGap, gap - (overflow / CGFloat(columns - 1)).rounded(.up))
    }

    private static func slots(count: Int, plan: SlotPlan) -> [CGRect] {
        (0..<count).map { index in plan.slot(at: index, of: count) }
    }
}

private struct SlotPlan {
    let columns: Int
    let icon: CGFloat
    let gap: CGFloat
    let width: CGFloat
    let metrics: OverlayMetrics

    func slot(at index: Int, of count: Int) -> CGRect {
        let slot = metrics.slotWidth(icon: icon)
        let rowHeight = metrics.rowHeight(icon: icon)
        let row = index / columns
        let column = index % columns
        let inRow = min(columns, count - row * columns)
        let origin = ((width - metrics.rowWidth(columns: inRow, icon: icon, gap: gap)) / 2).rounded()
        return CGRect(
            x: origin + CGFloat(column) * (slot + gap),
            y: metrics.padding + CGFloat(row) * (rowHeight + metrics.rowGap),
            width: slot,
            height: rowHeight
        )
    }
}
