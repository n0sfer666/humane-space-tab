import CoreGraphics

/// Everything except the icon is a share of the icon, the way the system switcher scales:
/// one row that keeps its proportions from three applications to forty.
public struct OverlayMetrics: Sendable, Equatable {
    public let largestIcon: CGFloat
    public let tiniestIcon: CGFloat
    public let gapShare: CGFloat
    public let paddingShare: CGFloat
    public let tileShare: CGFloat
    public let tileRadiusShare: CGFloat
    public let labelGap: CGFloat
    public let largestLabel: CGFloat
    public let smallestLabel: CGFloat
    public let widestShare: CGFloat
    /// How much wider than its icon a name may grow before it is truncated.
    public let widestName: CGFloat
    public let cornerRadius: CGFloat
    /// Past this many applications the icon stops shrinking and the ribbon scrolls instead.
    public let visibleLimit: Int

    public init(
        largestIcon: CGFloat = 100,
        tiniestIcon: CGFloat = 16,
        gapShare: CGFloat = 0.30,
        paddingShare: CGFloat = 0.30,
        tileShare: CGFloat = 0.08,
        tileRadiusShare: CGFloat = 0.20,
        labelGap: CGFloat = 2,
        largestLabel: CGFloat = 13,
        smallestLabel: CGFloat = 11,
        widestShare: CGFloat = 0.96,
        widestName: CGFloat = 2.5,
        cornerRadius: CGFloat = 26,
        visibleLimit: Int = 25
    ) {
        self.largestIcon = largestIcon
        self.tiniestIcon = tiniestIcon
        self.gapShare = gapShare
        self.paddingShare = paddingShare
        self.tileShare = tileShare
        self.tileRadiusShare = tileRadiusShare
        self.labelGap = labelGap
        self.largestLabel = largestLabel
        self.smallestLabel = smallestLabel
        self.widestShare = widestShare
        self.widestName = widestName
        self.cornerRadius = cornerRadius
        self.visibleLimit = visibleLimit
    }

    public func visible(count: Int) -> Int { min(count, visibleLimit) }

    public func gap(icon: CGFloat) -> CGFloat { (icon * gapShare).rounded() }

    public func padding(icon: CGFloat) -> CGFloat { (icon * paddingShare).rounded() }

    public func tilePadding(icon: CGFloat) -> CGFloat { (icon * tileShare).rounded() }

    public func tileRadius(icon: CGFloat) -> CGFloat { (icon * tileRadiusShare).rounded() }

    /// The name shrinks with the icon so a crowded ribbon stays legible without towering labels.
    public func labelSize(icon: CGFloat) -> CGFloat {
        guard largestIcon > tiniestIcon else { return largestLabel }
        let share = (icon - tiniestIcon) / (largestIcon - tiniestIcon)
        let size = smallestLabel + min(max(share, 0), 1) * (largestLabel - smallestLabel)
        return size.rounded()
    }

    public func labelHeight(icon: CGFloat) -> CGFloat { (labelSize(icon: icon) * 1.35).rounded(.up) }

    public func slotHeight(icon: CGFloat) -> CGFloat { icon + labelGap + labelHeight(icon: icon) }

    /// The name sits under its icon in a box no wider than the text itself, so a name that
    /// fits stays centred on the icon instead of being pushed aside by the empty half of a
    /// fixed box. A name too long for the room left at the ribbon's edge moves inwards by
    /// exactly what it takes to stay inside the panel, and is truncated past that.
    public func nameArea(under slot: CGRect, icon: CGFloat, text: CGFloat, panel: CGFloat) -> CGRect {
        let inset = padding(icon: icon)
        let budget = max(min(panel - inset * 2, icon * widestName), 0)
        let width = min(text.rounded(.up), budget)
        return CGRect(
            x: min(max(slot.midX - width / 2, inset), max(panel - width - inset, inset)),
            y: slot.minY + icon + labelGap,
            width: width,
            height: labelHeight(icon: icon)
        )
    }

    func rowWidth(count: Int, icon: CGFloat) -> CGFloat {
        guard count > 0 else { return 0 }
        return CGFloat(count) * icon + CGFloat(count - 1) * gap(icon: icon)
    }

    func ribbonWidth(count: Int, icon: CGFloat) -> CGFloat {
        rowWidth(count: count, icon: icon) + padding(icon: icon) * 2
    }
}
