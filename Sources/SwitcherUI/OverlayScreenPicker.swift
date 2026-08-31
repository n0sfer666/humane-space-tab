import CoreGraphics
import SwitcherCore

enum OverlayScreenPicker {
    /// Both signals are allowed to be missing: a pointer wanders off every display, and macOS
    /// tells a background application which screen holds keyboard focus only some of the time.
    /// Either way the ribbon still has to appear, so the choice falls through to the other
    /// signal and then to the primary display — nothing is picked only when there is no display.
    static func index(
        for choice: OverlayScreenChoice,
        pointer: CGPoint,
        frames: [CGRect],
        focused: Int?
    ) -> Int? {
        guard !frames.isEmpty else { return nil }
        let underPointer = frames.firstIndex { $0.contains(pointer) }
        let order = choice == .pointer ? [underPointer, focused] : [focused, underPointer]
        return order.compactMap { $0 }.first { frames.indices.contains($0) } ?? 0
    }
}
