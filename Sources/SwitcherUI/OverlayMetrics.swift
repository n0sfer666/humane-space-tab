import CoreGraphics
import SwitcherCore

/// Everything except the icon is a share of the icon, the way the system switcher scales:
/// one row that keeps its proportions from three applications to forty.
public struct OverlayMetrics: Sendable, Equatable {
    public let largestIcon: CGFloat
    public let tiniestIcon: CGFloat
    public let gapShare: CGFloat
    public let paddingShare: CGFloat
    /// How much larger the selected icon is drawn than the rest.
    public let selectedScale: CGFloat
    /// What is left of an unselected icon, so the selected one is the one the eye lands on.
    public let dimmed: CGFloat
    public let labelGap: CGFloat
    public let largestLabel: CGFloat
    public let smallestLabel: CGFloat
    public let widestShare: CGFloat
    public let cornerRadius: CGFloat
    /// The outline drawn around an icon, and how the selected one is told apart (S17).
    public let frame: FrameStyle
    public let selection: SelectionPreset

    public init(
        largestIcon: CGFloat = 100,
        tiniestIcon: CGFloat = 16,
        gapShare: CGFloat = 0.30,
        paddingShare: CGFloat = 0.30,
        selectedScale: CGFloat = 1.20,
        dimmed: CGFloat = 0.62,
        labelGap: CGFloat = 2,
        largestLabel: CGFloat = 13,
        smallestLabel: CGFloat = 11,
        widestShare: CGFloat = 0.96,
        cornerRadius: CGFloat = 26,
        frame: FrameStyle = .standard,
        selection: SelectionPreset = .standard
    ) {
        self.largestIcon = largestIcon
        self.tiniestIcon = tiniestIcon
        self.gapShare = gapShare
        self.paddingShare = paddingShare
        self.selectedScale = selectedScale
        self.dimmed = dimmed
        self.labelGap = labelGap
        self.largestLabel = largestLabel
        self.smallestLabel = smallestLabel
        self.widestShare = widestShare
        self.cornerRadius = cornerRadius
        self.frame = frame
        self.selection = selection
    }

    /// The numbers a profile chose, in the shape the ribbon draws with. Everything the
    /// layout needs beyond them — how small an icon may be squeezed, how the label scales —
    /// is not a setting and keeps the value it has always had.
    public init(appearance: Appearance) {
        self.init(
            largestIcon: CGFloat(appearance.iconSize),
            gapShare: CGFloat(appearance.gapShare),
            paddingShare: CGFloat(appearance.paddingShare),
            selectedScale: CGFloat(appearance.selection.selectedScale),
            dimmed: CGFloat(appearance.selection.dimmed),
            cornerRadius: CGFloat(appearance.cornerRadius),
            frame: appearance.frame,
            selection: appearance.selection
        )
    }

    public func visible(count: Int) -> Int { min(count, CarouselWindow.span) }

    public func gap(icon: CGFloat) -> CGFloat { (icon * gapShare).rounded() }

    public func padding(icon: CGFloat) -> CGFloat { (icon * paddingShare).rounded() }

    /// What the selected icon takes beyond its slot, on every side.
    public func growth(icon: CGFloat) -> CGFloat { (icon * (selectedScale - 1) / 2).rounded() }

    /// The name shrinks with the icon so a crowded ribbon stays legible without towering labels.
    public func labelSize(icon: CGFloat) -> CGFloat {
        guard largestIcon > tiniestIcon else { return largestLabel }
        let share = (icon - tiniestIcon) / (largestIcon - tiniestIcon)
        let size = smallestLabel + min(max(share, 0), 1) * (largestLabel - smallestLabel)
        return size.rounded()
    }

    public func labelHeight(icon: CGFloat) -> CGFloat { (labelSize(icon: icon) * 1.35).rounded(.up) }

    public func slotHeight(icon: CGFloat) -> CGFloat {
        icon + growth(icon: icon) + labelGap + labelHeight(icon: icon)
    }

    /// The name sits under its icon in a box no wider than the text itself, so a name that
    /// fits stays centred on the icon instead of being pushed aside by the empty half of a
    /// fixed box. A window title is as long as the document behind it, so the only bound
    /// left is the panel: a name too long for the room at the ribbon's edge moves inwards by
    /// exactly what it takes to stay inside, and is truncated past the panel's own width.
    public func nameArea(under slot: CGRect, icon: CGFloat, text: CGFloat, panel: CGFloat) -> CGRect {
        let inset = padding(icon: icon)
        let budget = max(panel - inset * 2, 0)
        let width = min(text.rounded(.up), budget)
        return CGRect(
            x: min(max(slot.midX - width / 2, inset), max(panel - width - inset, inset)),
            y: slot.minY + icon + growth(icon: icon) + labelGap,
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
