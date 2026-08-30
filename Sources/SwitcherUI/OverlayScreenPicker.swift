import CoreGraphics
import SwitcherCore

enum OverlayScreenPicker {
    /// The pointer is read when the session opens, so a pointer that has wandered off
    /// every display falls back to the screen with keyboard focus.
    static func index(
        for choice: OverlayScreenChoice,
        pointer: CGPoint,
        frames: [CGRect],
        focused: Int?
    ) -> Int? {
        guard choice == .pointer else { return focused }
        return frames.firstIndex { $0.contains(pointer) } ?? focused
    }
}
