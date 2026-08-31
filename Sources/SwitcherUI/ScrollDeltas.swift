import AppKit

/// A scroll event in the ribbon's terms: how far the content was pushed, with a wheel notch
/// worth exactly one step and a trackpad's fractions left as they are. Forward is the way a
/// list scrolls down, so the user's own scroll direction setting decides which way that is.
enum ScrollDeltas {
    static func of(_ event: NSEvent) -> (across: CGFloat, down: CGFloat) {
        let scale = event.hasPreciseScrollingDeltas ? 1 : ScrollSteps.threshold
        return (across: -event.scrollingDeltaX * scale, down: -event.scrollingDeltaY * scale)
    }
}
