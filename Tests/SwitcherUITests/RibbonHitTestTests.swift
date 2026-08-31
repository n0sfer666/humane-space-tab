import CoreGraphics
import Testing

@testable import SwitcherUI

@Suite("Ribbon hit test")
struct RibbonHitTestTests {
    private let screen = CGSize(width: 1728, height: 1117)

    private func layout(_ count: Int) -> OverlayLayout {
        OverlayLayout.compute(count: count, screen: screen)
    }

    private func middle(of layout: OverlayLayout, _ index: Int) -> CGPoint {
        CGPoint(x: layout.slots[index].midX, y: layout.slots[index].midY)
    }

    @Test("a point on a tile hits it")
    func hitsTile() {
        let layout = layout(5)
        #expect(RibbonHitTest.slot(at: middle(of: layout, 3), layout: layout, offset: 0) == 3)
    }

    @Test("a point in the gap belongs to the nearer tile")
    func gapHasNoDeadStripe() {
        let layout = layout(5)
        let gap = layout.slots[1].maxX + (layout.step - layout.iconSide) / 2
        let row = layout.slots[1].midY
        #expect(RibbonHitTest.slot(at: CGPoint(x: gap - 1, y: row), layout: layout, offset: 0) == 1)
        #expect(RibbonHitTest.slot(at: CGPoint(x: gap + 1, y: row), layout: layout, offset: 0) == 2)
    }

    @Test("a point outside the panel hits nothing")
    func missesOutsideThePanel() {
        let layout = layout(5)
        let inside = middle(of: layout, 0)
        let below = CGPoint(x: inside.x, y: layout.size.height + 1)
        let beyond = CGPoint(x: layout.size.width + 1, y: inside.y)
        #expect(RibbonHitTest.slot(at: CGPoint(x: inside.x, y: -1), layout: layout, offset: 0) == nil)
        #expect(RibbonHitTest.slot(at: below, layout: layout, offset: 0) == nil)
        #expect(RibbonHitTest.slot(at: CGPoint(x: -1, y: inside.y), layout: layout, offset: 0) == nil)
        #expect(RibbonHitTest.slot(at: beyond, layout: layout, offset: 0) == nil)
    }

    @Test("the padding beside the ribbon hits nothing")
    func missesThePadding() {
        let layout = layout(5)
        let row = layout.slots[0].midY
        let far = CGPoint(x: layout.size.width - 1, y: row)
        #expect(RibbonHitTest.slot(at: CGPoint(x: 1, y: row), layout: layout, offset: 0) == nil)
        #expect(RibbonHitTest.slot(at: far, layout: layout, offset: 0) == nil)
    }

    @Test("a scrolled ribbon hits what the user sees")
    func followsTheScrollOffset() {
        let layout = layout(30)
        let first = middle(of: layout, 0)
        #expect(RibbonHitTest.slot(at: first, layout: layout, offset: 4) == 4)
        #expect(RibbonHitTest.slot(at: first, layout: layout, offset: 0) == 0)
    }

    @Test("an empty ribbon hits nothing")
    func missesOnAnEmptyRibbon() {
        #expect(RibbonHitTest.slot(at: .zero, layout: .empty, offset: 0) == nil)
    }
}
