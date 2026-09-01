/// The outline drawn around an icon. Its width is in points because a hairline is a hairline
/// at any icon size; the room it keeps around the icon is a share of the icon, so a frame
/// stays as tight on a small ribbon as it looks on a large one.
public struct FrameStyle: Equatable, Sendable, Codable {
    public static let standard = FrameStyle()
    public static let widthRange: ClosedRange<Double> = 0...4
    public static let radiusRange: ClosedRange<Double> = 0...24

    public let width: Double
    public let paddingShare: Double
    public let radius: Double

    public init(width: Double = 0, paddingShare: Double = 0.08, radius: Double = 10) {
        self.width = width
        self.paddingShare = paddingShare
        self.radius = radius
    }

    public var isDrawn: Bool { width > 0 }

    public func padding(icon: Double) -> Double { (icon * paddingShare).rounded() }
}
