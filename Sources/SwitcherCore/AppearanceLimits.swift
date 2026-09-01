/// Where the sliders stop. Two kinds of bound live here. One is the screen: an icon may not
/// take a quarter of it, whatever the person drags the slider to. The other is the ribbon's
/// own proportions — the margin and the gaps are measured in icons, and together they may
/// not take more room than the icons themselves, so a ribbon stays a row of applications
/// rather than a field of air. Both are shared out: widening the gaps is what leaves the
/// margin less to grow into, which is why the form asks for these ranges every time it draws.
public enum AppearanceLimits {
    /// The screen a setting is judged against when there is no screen to hand — decoding a
    /// stored profile, say. Narrower than most displays, so the tamed value fits them too.
    public static let referenceWidth: Double = 1280
    /// The most of the screen a single icon may take.
    public static let iconShare: Double = 0.25
    /// What the margin and the gaps may take together, per icon in the ribbon.
    public static let spacingShare: Double = 0.5
    public static let cornerRadiusRange: ClosedRange<Double> = 0...40
    /// How faint the icons may be made. The top of the range is the strength the ribbon has
    /// always drawn them at; below it a person is free to go until they can barely be seen.
    public static let iconOpacityRange: ClosedRange<Double> = 0.1...1
    public static let smallestIcon: Double = 16
    public static let largestIcon: Double = 128
    public static let shareCeiling: Double = 1

    public static func iconSize(
        _ appearance: Appearance,
        screenWidth: Double = referenceWidth
    ) -> ClosedRange<Double> {
        let room = iconShare * max(screenWidth, smallestIcon)
        return smallestIcon...max(smallestIcon, min(largestIcon, room))
    }

    public static func paddingShare(_ appearance: Appearance) -> ClosedRange<Double> {
        let slots = Double(slotCount(appearance))
        return 0...ceiling((budget(appearance) - (slots - 1) * appearance.gapShare) / 2)
    }

    public static func gapShare(_ appearance: Appearance) -> ClosedRange<Double> {
        let slots = Double(slotCount(appearance))
        guard slots > 1 else { return 0...shareCeiling }
        return 0...ceiling((budget(appearance) - 2 * appearance.paddingShare) / (slots - 1))
    }

    /// A frame lives in the panel's margin: what it takes around the icon, plus its own
    /// stroke, cannot be more than the room between the icons and the panel's edge.
    public static func framePaddingShare(_ appearance: Appearance) -> ClosedRange<Double> {
        let icon = appearance.iconSize
        guard icon > 0 else { return 0...0 }
        return 0...max(0, min(0.4, appearance.paddingShare - appearance.frame.width / icon))
    }

    /// The stored settings, brought inside the bounds above without changing anything that
    /// was already inside them. Order matters: the gaps are settled before the margin, which
    /// is left with what they did not take, and the frame last of all.
    public static func normalise(_ appearance: Appearance, screenWidth: Double = referenceWidth) -> Appearance {
        var tamed = appearance.with(
            paddingShare: clamp(appearance.paddingShare, into: 0...shareCeiling),
            gapShare: clamp(appearance.gapShare, into: 0...shareCeiling),
            cornerRadius: clamp(appearance.cornerRadius, into: cornerRadiusRange),
            iconOpacity: clamp(appearance.iconOpacity, into: iconOpacityRange),
            frame: FrameStyle(
                width: clamp(appearance.frame.width, into: FrameStyle.widthRange),
                paddingShare: clamp(appearance.frame.paddingShare, into: 0...0.4),
                radius: clamp(appearance.frame.radius, into: FrameStyle.radiusRange)
            ),
            background: appearance.background.normalised,
            carousel: CarouselSetting(
                isEnabled: appearance.carousel.isEnabled,
                slots: appearance.carousel.slots
            )
        )
        tamed = tamed.with(iconSize: clamp(tamed.iconSize, into: iconSize(tamed, screenWidth: screenWidth)))
        tamed = tamed.with(gapShare: clamp(tamed.gapShare, into: gapShare(tamed)))
        tamed = tamed.with(paddingShare: clamp(tamed.paddingShare, into: paddingShare(tamed)))
        return tamed.with(
            frame: FrameStyle(
                width: tamed.frame.width,
                paddingShare: clamp(tamed.frame.paddingShare, into: framePaddingShare(tamed)),
                radius: tamed.frame.radius
            )
        )
    }

    public static func clamp(_ value: Double, into range: ClosedRange<Double>) -> Double {
        guard value.isFinite else { return range.lowerBound }
        return min(max(value, range.lowerBound), range.upperBound)
    }

    /// How many icons a ribbon has to fit at once. A still ribbon has no bound of its own —
    /// it shrinks its icons until the row fits — so it is judged by the shortest turning
    /// ribbon, the size at which a person is likely to be reading it.
    private static func slotCount(_ appearance: Appearance) -> Int {
        appearance.carousel.isEnabled ? appearance.carousel.slots : CarouselSetting.slotRange.lowerBound
    }

    private static func budget(_ appearance: Appearance) -> Double {
        spacingShare * Double(slotCount(appearance))
    }

    private static func ceiling(_ room: Double) -> Double {
        guard room.isFinite else { return 0 }
        return max(0, min(shareCeiling, room))
    }
}
