import CoreGraphics

public struct OverlayMetrics: Sendable, Equatable {
    public let largestIcon: CGFloat
    public let smallestIcon: CGFloat
    public let tiniestIcon: CGFloat
    public let selectedScale: CGFloat
    public let tilePadding: CGFloat
    public let smallestGap: CGFloat
    public let largestGap: CGFloat
    public let rowGap: CGFloat
    public let padding: CGFloat
    public let labelGap: CGFloat
    public let largestLabel: CGFloat
    public let smallestLabel: CGFloat
    public let targetShare: CGFloat
    public let widestShare: CGFloat
    public let tallestShare: CGFloat
    public let cornerRadius: CGFloat
    public let tileRadius: CGFloat

    public init(
        largestIcon: CGFloat = 128,
        smallestIcon: CGFloat = 48,
        tiniestIcon: CGFloat = 16,
        selectedScale: CGFloat = 1.12,
        tilePadding: CGFloat = 8,
        smallestGap: CGFloat = 4,
        largestGap: CGFloat = 15,
        rowGap: CGFloat = 8,
        padding: CGFloat = 10,
        labelGap: CGFloat = 2,
        largestLabel: CGFloat = 13,
        smallestLabel: CGFloat = 9,
        targetShare: CGFloat = 0.80,
        widestShare: CGFloat = 0.90,
        tallestShare: CGFloat = 0.80,
        cornerRadius: CGFloat = 24,
        tileRadius: CGFloat = 16
    ) {
        self.largestIcon = largestIcon
        self.smallestIcon = smallestIcon
        self.tiniestIcon = tiniestIcon
        self.selectedScale = selectedScale
        self.tilePadding = tilePadding
        self.smallestGap = smallestGap
        self.largestGap = largestGap
        self.rowGap = rowGap
        self.padding = padding
        self.labelGap = labelGap
        self.largestLabel = largestLabel
        self.smallestLabel = smallestLabel
        self.targetShare = targetShare
        self.widestShare = widestShare
        self.tallestShare = tallestShare
        self.cornerRadius = cornerRadius
        self.tileRadius = tileRadius
    }

    func slotWidth(icon: CGFloat) -> CGFloat { (icon * selectedScale + tilePadding * 2).rounded() }

    func rowHeight(icon: CGFloat) -> CGFloat {
        (icon * selectedScale + tilePadding * 2 + labelGap + labelHeight(icon: icon)).rounded()
    }

    /// The name shrinks with the icon so a crowded ribbon stays legible without towering labels.
    public func labelSize(icon: CGFloat) -> CGFloat {
        guard largestIcon > smallestIcon else { return largestLabel }
        let share = (icon - smallestIcon) / (largestIcon - smallestIcon)
        let size = smallestLabel + min(max(share, 0), 1) * (largestLabel - smallestLabel)
        return size.rounded()
    }

    public func labelHeight(icon: CGFloat) -> CGFloat { (labelSize(icon: icon) * 1.35).rounded(.up) }

    func rowWidth(columns: Int, icon: CGFloat, gap: CGFloat) -> CGFloat {
        guard columns > 0 else { return 0 }
        return CGFloat(columns) * slotWidth(icon: icon) + CGFloat(columns - 1) * gap
    }
}
