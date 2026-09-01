import SwitcherCore

/// The numbers the Appearance tab offers, each with the name it goes under, the unit it is
/// read in, where it lives in an `Appearance` and what it may be right now. Keeping them in
/// one table is what lets the form draw six identical rows and re-bound all of them after
/// any change, without six copies of the same three lines.
enum AppearanceMeasure: CaseIterable {
    case iconSize
    case ribbonPadding
    case gap
    case cornerRadius
    case frameWidth
    case framePadding

    var label: String {
        switch self {
        case .iconSize: "Icon size"
        case .ribbonPadding: "Ribbon padding"
        case .gap: "Space between icons"
        case .cornerRadius: "Corner radius"
        case .frameWidth: "Frame around the icon"
        case .framePadding: "Frame padding"
        }
    }

    var unit: MeasureRow.Unit {
        switch self {
        case .iconSize, .cornerRadius, .frameWidth: .points
        case .ribbonPadding, .gap, .framePadding: .percent
        }
    }

    func value(in appearance: Appearance) -> Double {
        switch self {
        case .iconSize: appearance.iconSize
        case .ribbonPadding: appearance.paddingShare
        case .gap: appearance.gapShare
        case .cornerRadius: appearance.cornerRadius
        case .frameWidth: appearance.frame.width
        case .framePadding: appearance.frame.paddingShare
        }
    }

    func applying(_ value: Double, to appearance: Appearance) -> Appearance {
        switch self {
        case .iconSize: appearance.with(iconSize: value)
        case .ribbonPadding: appearance.with(paddingShare: value)
        case .gap: appearance.with(gapShare: value)
        case .cornerRadius: appearance.with(cornerRadius: value)
        case .frameWidth: appearance.with(frame: appearance.frame.with(width: value))
        case .framePadding: appearance.with(frame: appearance.frame.with(paddingShare: value))
        }
    }

    func range(in appearance: Appearance, screenWidth: Double) -> ClosedRange<Double> {
        switch self {
        case .iconSize: AppearanceLimits.iconSize(appearance, screenWidth: screenWidth)
        case .ribbonPadding: AppearanceLimits.paddingShare(appearance)
        case .gap: AppearanceLimits.gapShare(appearance)
        case .cornerRadius: AppearanceLimits.cornerRadiusRange
        case .frameWidth: FrameStyle.widthRange
        case .framePadding: AppearanceLimits.framePaddingShare(appearance)
        }
    }
}
