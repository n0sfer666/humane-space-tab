import CoreGraphics

/// Turns a stream of scroll deltas into whole steps of the selection: one entry per notch,
/// forward when the gesture goes down or right. A trackpad delivers fractions of a notch, so
/// the remainder is kept between events — and dropped when the gesture turns around, since a
/// reversal is a new intent rather than the continuation of the old one.
public struct ScrollSteps: Equatable, Sendable {
    public static let threshold: CGFloat = 12

    private var pending: CGFloat = 0

    public init() {}

    public mutating func reset() { pending = 0 }

    public mutating func steps(across: CGFloat, down: CGFloat) -> Int {
        let delta = abs(across) > abs(down) ? across : down
        guard delta != 0 else { return 0 }
        if (delta < 0) != (pending < 0) { pending = 0 }
        pending += delta
        let steps = Int(pending / Self.threshold)
        pending -= CGFloat(steps) * Self.threshold
        return steps
    }
}
