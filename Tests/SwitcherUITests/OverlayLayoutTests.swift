import CoreGraphics
import Testing

@testable import SwitcherUI

@Suite("Overlay layout")
struct OverlayLayoutTests {
    private let screen = CGSize(width: 1440, height: 900)
    private let metrics = OverlayMetrics()

    @Test("a few applications keep the largest icon in one row")
    func fewApplicationsStayLarge() {
        let layout = OverlayLayout.compute(count: 3, screen: screen, metrics: metrics)
        #expect(layout.iconSide == metrics.largestIcon)
        #expect(layout.columns == 3)
        #expect(Set(layout.slots.map(\.origin.y)).count == 1)
    }

    @Test("a crowded row shrinks the icon instead of wrapping")
    func crowdedRowShrinks() {
        let layout = OverlayLayout.compute(count: 12, screen: screen, metrics: metrics)
        #expect(layout.columns == 12)
        #expect(layout.iconSide < metrics.largestIcon)
        #expect(layout.iconSide >= metrics.smallestIcon)
    }

    @Test("more applications than fit at the smallest icon wrap into balanced rows")
    func tooManyWrap() {
        let layout = OverlayLayout.compute(count: 40, screen: screen, metrics: metrics)
        #expect(layout.iconSide == metrics.smallestIcon)
        #expect(layout.columns < 40)
        let rows = Set(layout.slots.map(\.origin.y))
        #expect(rows.count > 1)
        #expect(layout.columns * rows.count >= 40)
        #expect((layout.columns - 1) * rows.count < 40)
    }

    @Test("every row is centred in the panel")
    func rowsAreCentred() {
        let layout = OverlayLayout.compute(count: 40, screen: screen, metrics: metrics)
        let rows = Set(layout.slots.map(\.origin.y)).sorted()
        for row in rows {
            let inRow = layout.slots.filter { $0.origin.y == row }
            guard let leading = inRow.first, let trailing = inRow.last else { continue }
            let left: CGFloat = leading.minX
            let right: CGFloat = layout.size.width - trailing.maxX
            #expect(abs(left - right) <= 1)
        }
    }

    @Test("the ribbon never runs wider than the widest share")
    func widthStaysUnderTheCap() {
        for count in 1...64 {
            let layout = OverlayLayout.compute(count: count, screen: screen, metrics: metrics)
            #expect(layout.size.width <= (screen.width * metrics.widestShare).rounded() + 1)
        }
    }

    @Test("gaps grow toward the cap when the ribbon has room")
    func gapsGrowToTheCap() {
        let layout = OverlayLayout.compute(count: 6, screen: screen, metrics: metrics)
        let gap = layout.slots[1].minX - layout.slots[0].maxX
        #expect(gap == metrics.largestGap)
    }

    @Test("no gap ever exceeds the cap")
    func gapsNeverExceedTheCap() {
        for count in 2...64 {
            let layout = OverlayLayout.compute(count: count, screen: screen, metrics: metrics)
            #expect(layout.slots[1].minX - layout.slots[0].maxX <= metrics.largestGap)
        }
    }

    @Test("a ribbon that only just fits keeps the smallest gap")
    func crowdedKeepsSmallestGap() {
        let layout = OverlayLayout.compute(count: 12, screen: screen, metrics: metrics)
        let gap = layout.slots[1].minX - layout.slots[0].maxX
        #expect(gap == metrics.smallestGap)
    }

    @Test("the height follows the number of rows")
    func heightFollowsRows() {
        let one = OverlayLayout.compute(count: 3, screen: screen, metrics: metrics)
        let many = OverlayLayout.compute(count: 40, screen: screen, metrics: metrics)
        #expect(many.size.height > one.size.height)
    }

    @Test("a slot already fits the enlarged selected icon")
    func slotFitsSelection() {
        let layout = OverlayLayout.compute(count: 5, screen: screen, metrics: metrics)
        for slot in layout.slots {
            #expect(slot.width >= layout.iconSide * metrics.selectedScale)
            #expect(slot.height >= layout.iconSide * metrics.selectedScale + metrics.labelHeight(icon: layout.iconSide))
        }
    }

    @Test("a single application produces one slot and no negative gaps")
    func singleApplication() {
        let layout = OverlayLayout.compute(count: 1, screen: screen, metrics: metrics)
        #expect(layout.slots.count == 1)
        #expect(layout.columns == 1)
        #expect(layout.slots[0].minX == metrics.padding)
    }

    @Test("the name shrinks with the icon and never below the floor")
    func labelFollowsIcon() {
        let roomy = OverlayLayout.compute(count: 4, screen: screen, metrics: metrics)
        let crowded = OverlayLayout.compute(count: 16, screen: screen, metrics: metrics)
        #expect(metrics.labelSize(icon: roomy.iconSide) == metrics.largestLabel)
        #expect(metrics.labelSize(icon: crowded.iconSide) < metrics.largestLabel)
        #expect(metrics.labelSize(icon: crowded.iconSide) >= metrics.smallestLabel)
    }

    @Test("no applications produce no layout")
    func noApplications() {
        #expect(OverlayLayout.compute(count: 0, screen: screen, metrics: metrics) == .empty)
    }

    @Test("the ribbon fits both budgets on every screen", arguments: [1280.0, 1440.0, 1728.0, 2560.0])
    func fitsBothBudgets(width: CGFloat) {
        let screen = CGSize(width: width, height: (width * 0.625).rounded())
        for count in 1...64 {
            let layout = OverlayLayout.compute(count: count, screen: screen, metrics: metrics)
            #expect(layout.size.width <= (screen.width * metrics.widestShare).rounded() + 1)
            #expect(layout.size.height <= (screen.height * metrics.tallestShare).rounded() + 1)
        }
    }

    @Test("slots never overlap on any screen", arguments: [1280.0, 1440.0, 1728.0, 2560.0])
    func slotsNeverOverlap(width: CGFloat) {
        let screen = CGSize(width: width, height: (width * 0.625).rounded())
        for count in 2...64 {
            let slots = OverlayLayout.compute(count: count, screen: screen, metrics: metrics).slots
            for (index, slot) in slots.enumerated().dropFirst()
            where slot.origin.y == slots[index - 1].origin.y {
                #expect(slot.minX >= slots[index - 1].maxX)
            }
        }
    }

    @Test(
        "the measured ribbon matches the table in the spec",
        arguments: [
            [3, 128, 15, 1], [6, 128, 15, 1], [10, 119, 4, 1],
            [16, 68, 4, 1], [24, 48, 15, 2], [40, 48, 4, 2],
        ]
    )
    func matchesTheSpec(row: [Int]) {
        let layout = OverlayLayout.compute(
            count: row[0],
            screen: CGSize(width: 1728, height: 1117),
            metrics: metrics
        )
        #expect(layout.iconSide == CGFloat(row[1]))
        #expect(layout.slots[1].minX - layout.slots[0].maxX == CGFloat(row[2]))
        #expect(Set(layout.slots.map(\.origin.y)).count == row[3])
    }

    @Test("a count that cannot fit the height shrinks past the smallest icon")
    func heightBudgetShrinksTheIcon() {
        let short = CGSize(width: 1280, height: 800)
        let layout = OverlayLayout.compute(count: 154, screen: short, metrics: metrics)
        #expect(layout.iconSide < metrics.smallestIcon)
        #expect(layout.iconSide >= metrics.tiniestIcon)
        #expect(layout.size.height <= short.height * metrics.tallestShare)
    }
}
