import CoreGraphics
import SwitcherCore

/// The pointer's half of the ribbon: what a move, a click and a scroll mean over the geometry
/// the ribbon was last drawn with. It is arithmetic over the same layout `draw` uses, so the
/// view stays a view and the semantics of a click are testable without a window server.
struct RibbonMouse {
    private var layout = OverlayLayout.empty
    private var offset = 0
    private var selection = 0
    private var pressed: Int?
    private var scroll = ScrollSteps()

    mutating func rendered(layout: OverlayLayout, offset: Int, selection: Int) {
        self.layout = layout
        self.offset = offset
        self.selection = selection
    }

    /// Hovering follows movement, never presence: the ribbon opens under a resting pointer far
    /// more often than the user means to point at it, and the selection the keyboard just made
    /// must survive that.
    mutating func moved(to point: CGPoint) -> RibbonGesture? {
        guard let slot = slot(at: point), slot != selection else { return nil }
        return .select(slot)
    }

    /// A session ends with whatever the pointer was in the middle of; the next one starts
    /// with none of it.
    mutating func reset() {
        pressed = nil
        scroll.reset()
    }

    mutating func press(at point: CGPoint) {
        pressed = slot(at: point)
    }

    /// A click that wanders off the tile it started on is no click, the way a button treats a
    /// drag off itself.
    mutating func release(at point: CGPoint) -> RibbonGesture? {
        defer { pressed = nil }
        guard let pressed, slot(at: point) == pressed else { return nil }
        return .commit(pressed)
    }

    mutating func scrolled(across: CGFloat, down: CGFloat) -> (direction: SelectionDirection, count: Int)? {
        let steps = scroll.steps(across: across, down: down)
        guard steps != 0 else { return nil }
        return (direction: steps > 0 ? .forward : .backward, count: abs(steps))
    }

    private func slot(at point: CGPoint) -> Int? {
        RibbonHitTest.slot(at: point, layout: layout, offset: offset)
    }
}
