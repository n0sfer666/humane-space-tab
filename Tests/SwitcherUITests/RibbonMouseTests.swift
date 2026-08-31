import CoreGraphics
import SwitcherCore
import Testing

@testable import SwitcherUI

@Suite("Ribbon mouse")
struct RibbonMouseTests {
    private func mouse(selection: Int = 1, count: Int = 5) -> RibbonMouse {
        var mouse = RibbonMouse()
        mouse.rendered(
            layout: OverlayLayout.compute(count: count, screen: CGSize(width: 1728, height: 1117)),
            window: CarouselWindow.indices(count: count, selection: selection),
            selection: selection
        )
        return mouse
    }

    private func wrapped(count: Int = 20, selection: Int = 0) -> RibbonMouse {
        var mouse = RibbonMouse()
        mouse.rendered(
            layout: OverlayLayout.compute(count: count, screen: CGSize(width: 1728, height: 1117)),
            window: CarouselWindow.indices(count: count, selection: selection),
            selection: selection
        )
        return mouse
    }

    private func tile(_ index: Int, count: Int = 5) -> CGPoint {
        let layout = OverlayLayout.compute(count: count, screen: CGSize(width: 1728, height: 1117))
        return CGPoint(x: layout.slots[index].midX, y: layout.slots[index].midY)
    }

    @Test("moving onto another tile selects the entry that tile carries")
    func moveSelects() {
        var mouse = mouse()
        #expect(mouse.moved(to: tile(3)) == .select(3))
    }

    @Test("moving onto the selected tile asks for nothing")
    func moveOntoSelectionIsSilent() {
        var mouse = mouse()
        #expect(mouse.moved(to: tile(1)) == nil)
    }

    @Test("moving outside the ribbon asks for nothing")
    func moveOutsideIsSilent() {
        var mouse = mouse()
        #expect(mouse.moved(to: CGPoint(x: -10, y: -10)) == nil)
    }

    @Test("a click that begins and ends on one tile commits it")
    func clickCommits() {
        var mouse = mouse()
        mouse.press(at: tile(2))
        #expect(mouse.release(at: tile(2)) == .commit(2))
    }

    @Test("a click that ends on another tile commits nothing")
    func draggedClickIsDropped() {
        var mouse = mouse()
        mouse.press(at: tile(2))
        #expect(mouse.release(at: tile(3)) == nil)
    }

    @Test("a release with no press commits nothing")
    func strayReleaseIsDropped() {
        var mouse = mouse()
        #expect(mouse.release(at: tile(2)) == nil)
    }

    @Test("a second release after a click commits nothing")
    func clickIsSpentOnce() {
        var mouse = mouse()
        mouse.press(at: tile(2))
        _ = mouse.release(at: tile(2))
        #expect(mouse.release(at: tile(2)) == nil)
    }

    @Test("a session that ends forgets the press it was holding")
    func resetForgetsThePress() {
        var mouse = mouse()
        mouse.press(at: tile(2))
        mouse.reset()
        #expect(mouse.release(at: tile(2)) == nil)
    }

    @Test("a scroll shorter than a notch steps nothing")
    func smallScrollIsSilent() {
        var mouse = mouse()
        #expect(mouse.scrolled(across: 0, down: ScrollSteps.threshold / 3) == nil)
    }

    @Test("a scroll steps the selection once per notch")
    func scrollSteps() {
        var mouse = mouse()
        let scroll = mouse.scrolled(across: 0, down: ScrollSteps.threshold * 2)
        #expect(scroll?.direction == .forward)
        #expect(scroll?.count == 2)
    }

    @Test("a scroll the other way steps backward")
    func scrollStepsBackward() {
        var mouse = mouse()
        let scroll = mouse.scrolled(across: 0, down: -ScrollSteps.threshold)
        #expect(scroll?.direction == .backward)
        #expect(scroll?.count == 1)
    }

    @Test("on a full carousel a slot means the entry it carries")
    func slotsCarryTheirEntry() {
        var mouse = wrapped()
        #expect(mouse.moved(to: tile(0, count: 20)) == .select(16))
        var clicking = wrapped()
        clicking.press(at: tile(9, count: 20))
        #expect(clicking.release(at: tile(9, count: 20)) == .commit(5))
    }

    @Test("a ribbon that has not been drawn answers nothing")
    func undrawnRibbonIsSilent() {
        var mouse = RibbonMouse()
        #expect(mouse.moved(to: tile(1)) == nil)
        mouse.press(at: tile(1))
        #expect(mouse.release(at: tile(1)) == nil)
    }
}
