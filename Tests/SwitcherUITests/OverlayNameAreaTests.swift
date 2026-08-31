import CoreGraphics
import Testing

@testable import SwitcherUI

@Suite("Overlay name area")
struct OverlayNameAreaTests {
    private let metrics = OverlayMetrics()
    private let layout = OverlayLayout.compute(count: 40, screen: CGSize(width: 1440, height: 900))
    private let middle = 4

    private func area(_ index: Int, text: CGFloat) -> CGRect {
        metrics.nameArea(
            under: layout.slots[index],
            icon: layout.iconSide,
            text: text,
            panel: layout.size.width
        )
    }

    @Test("a name that fits stays centred on its icon, wherever the icon is")
    func namesStayOnTheirIcon() {
        for index in [0, middle, layout.visible - 1] {
            let slot = layout.slots[index]
            #expect(area(index, text: slot.width).midX == slot.midX)
        }
    }

    @Test("a name wider than its icon still sits on it while there is room")
    func widerNamesStayCentred() {
        let slot = layout.slots[middle]
        #expect(area(middle, text: slot.width * 2).midX == slot.midX)
    }

    @Test("a name too wide for the first slot moves in only as far as the panel")
    func theFirstNameMovesInside() {
        let inset = metrics.padding(icon: layout.iconSide)
        let area = area(0, text: layout.iconSide * 3)
        #expect(area.minX == inset)
        #expect(area.midX > layout.slots[0].midX)
    }

    @Test("a name too wide for the last slot stops at the far edge")
    func theLastNameMovesInside() {
        let last = layout.visible - 1
        let inset = metrics.padding(icon: layout.iconSide)
        let area = area(last, text: layout.iconSide * 3)
        #expect(area.maxX == layout.size.width - inset)
        #expect(area.midX < layout.slots[last].midX)
    }

    @Test("a name past the panel is truncated rather than allowed to grow")
    func longNamesAreCapped() {
        let inset = metrics.padding(icon: layout.iconSide)
        let area = area(middle, text: 10_000)
        #expect(area.width == layout.size.width - inset * 2)
        #expect(area.minX == inset)
    }

    @Test("the name sits under its icon")
    func theNameSitsUnderTheIcon() {
        let area = area(middle, text: layout.iconSide)
        let below = layout.iconSide + metrics.growth(icon: layout.iconSide) + metrics.labelGap
        #expect(area.minY == layout.slots[middle].minY + below)
        #expect(area.height == metrics.labelHeight(icon: layout.iconSide))
    }
}
