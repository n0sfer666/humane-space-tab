/// What the panel is made of. Each style carries only the number it can act on: the glass
/// keeps the system's material and darkens it just enough to keep light labels readable,
/// the other two have no material to speak of and are described by their opacity alone.
public enum BackgroundStyle: Equatable, Sendable, Codable {
    case glass(scrim: Double)
    case transparent(opacity: Double)
    case solid(opacity: Double)

    public static let standard = BackgroundStyle.glass(scrim: 0.15)
    public static let scrimRange: ClosedRange<Double> = 0...0.4
    public static let opacityRange: ClosedRange<Double> = 0.1...1

    public var normalised: BackgroundStyle {
        switch self {
        case .glass(let scrim): .glass(scrim: Self.clamp(scrim, into: Self.scrimRange))
        case .transparent(let opacity): .transparent(opacity: Self.clamp(opacity, into: Self.opacityRange))
        case .solid(let opacity): .solid(opacity: Self.clamp(opacity, into: Self.opacityRange))
        }
    }

    /// The number the style is drawn with, whichever one it is: the form has a single
    /// slider whose meaning changes with the style, and this is what it shows.
    public var level: Double {
        switch self {
        case .glass(let scrim): scrim
        case .transparent(let opacity), .solid(let opacity): opacity
        }
    }

    public var range: ClosedRange<Double> {
        switch self {
        case .glass: Self.scrimRange
        case .transparent, .solid: Self.opacityRange
        }
    }

    public func with(level: Double) -> BackgroundStyle {
        switch self {
        case .glass: .glass(scrim: level).normalised
        case .transparent: .transparent(opacity: level).normalised
        case .solid: .solid(opacity: level).normalised
        }
    }

    private static func clamp(_ value: Double, into range: ClosedRange<Double>) -> Double {
        guard value.isFinite else { return range.lowerBound }
        return min(max(value, range.lowerBound), range.upperBound)
    }
}
