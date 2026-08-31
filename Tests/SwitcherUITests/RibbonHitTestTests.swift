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
        #expect(RibbonHitTest.slot(at: middle(of: layout, 3), layout: layout) == 3)
    }

    @Test("a point in the gap belongs to the nearer tile")
    func gapHasNoDeadStripe() {
        let layout = layout(5)
        let gap = layout.slots[1].maxX + (layout.step - layout.iconSide) / 2
        let row = layout.slots[1].midY
        #expect(RibbonHitTest.slot(at: CGPoint(x: gap - 1, y: row), layout: layout) == 1)
        #expect(RibbonHitTest.slot(at: CGPoint(x: gap + 1, y: row), layout: layout) == 2)
    }

    @Test("a point outside the panel hits nothing")
    func missesOutsideThePanel() {
        let layout = layout(5)
        let inside = middle(of: layout, 0)
        let below = CGPoint(x: inside.x, y: layout.size.height + 1)
        let beyond = CGPoint(x: layout.size.width + 1, y: inside.y)
        #expect(RibbonHitTest.slot(at: CGPoint(x: inside.x, y: -1), layout: layout) == nil)
        #expect(RibbonHitTest.slot(at: below, layout: layout) == nil)
        #expect(RibbonHitTest.slot(at: CGPoint(x: -1, y: inside.y), layout: layout) == nil)
        #expect(RibbonHitTest.slot(at: beyond, layout: layout) == nil)
    }

    @Test("the padding beside the ribbon hits nothing")
    func missesThePadding() {
        let layout = layout(5)
        let row = layout.slots[0].midY
        let far = CGPoint(x: layout.size.width - 1, y: row)
        #expect(RibbonHitTest.slot(at: CGPoint(x: 1, y: row), layout: layout) == nil)
        #expect(RibbonHitTest.slot(at: far, layout: layout) == nil)
    }

    @Test("a crowded Space is hit by slot, not by application")
    func crowdedRibbonHitsItsSlots() {
        let layout = layout(60)
        #expect(RibbonHitTest.slot(at: middle(of: layout, 0), layout: layout) == 0)
        #expect(RibbonHitTest.slot(at: middle(of: layout, layout.visible - 1), layout: layout) == layout.visible - 1)
    }

    @Test("an empty ribbon hits nothing")
    func missesOnAnEmptyRibbon() {
        #expect(RibbonHitTest.slot(at: .zero, layout: .empty) == nil)
    }
}
