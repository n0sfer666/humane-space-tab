import CoreGraphics
import SwitcherCore
import Testing

@testable import SwitcherUI

@Suite("Overlay layout")
struct OverlayLayoutTests {
    private let screen = CGSize(width: 1440, height: 900)
    private let metrics = OverlayMetrics()

    @Test("a few applications keep the largest icon")
    func fewApplicationsStayLarge() {
        let layout = OverlayLayout.compute(count: 3, screen: screen, metrics: metrics)
        #expect(layout.iconSide == metrics.largestIcon)
        #expect(layout.slots.count == 3)
    }

    @Test("a full ribbon on a narrow screen shrinks the icon and never wraps")
    func narrowScreensShrink() {
        for width in [900.0, 1000.0, 1100.0] {
            let layout = OverlayLayout.compute(
                count: CarouselWindow.span,
                screen: CGSize(width: width, height: 700),
                metrics: metrics
            )
            #expect(layout.iconSide < metrics.largestIcon)
            #expect(Set(layout.slots.map(\.origin.y)).count == 1)
        }
    }

    @Test("the ribbon never runs wider than the widest share")
    func widthStaysUnderTheCap() {
        for count in 1...64 {
            let layout = OverlayLayout.compute(count: count, screen: screen, metrics: metrics)
            #expect(layout.size.width <= (screen.width * metrics.widestShare).rounded() + 1)
        }
    }

    @Test("gaps and paddings stay shares of the icon")
    func spacingFollowsTheIcon() {
        for count in 2...CarouselWindow.span {
            let layout = OverlayLayout.compute(count: count, screen: screen, metrics: metrics)
            let icon = layout.iconSide
            #expect(layout.slots[1].minX - layout.slots[0].maxX == metrics.gap(icon: icon))
            #expect(layout.slots[0].minX == metrics.padding(icon: icon))
            #expect(layout.slots[0].minY == metrics.padding(icon: icon))
        }
    }

    @Test("past a full window the ribbon stops growing and the entries move through it")
    func beyondTheWindowTheRibbonHoldsStill() {
        let full = OverlayLayout.compute(count: CarouselWindow.span, screen: screen, metrics: metrics)
        for count in [CarouselWindow.span + 1, 40, 120] {
            let layout = OverlayLayout.compute(count: count, screen: screen, metrics: metrics)
            #expect(layout.size == full.size)
            #expect(layout.visible == CarouselWindow.span)
            #expect(layout.slots == full.slots)
        }
    }

    @Test("every slot is inside the panel")
    func slotsAreInsideThePanel() {
        for count in [1, 4, CarouselWindow.span, 40] {
            let layout = OverlayLayout.compute(count: count, screen: screen, metrics: metrics)
            #expect(layout.slots.allSatisfy { $0.maxX <= layout.size.width })
            #expect(layout.slots.count == min(count, CarouselWindow.span))
        }
    }

    @Test("the step is one icon plus one gap")
    func stepMatchesTheSpacing() {
        let layout = OverlayLayout.compute(count: 10, screen: screen, metrics: metrics)
        #expect(layout.step == layout.iconSide + metrics.gap(icon: layout.iconSide))
    }

    @Test("a slot holds the icon and the room the name needs")
    func slotHoldsIconAndName() {
        let layout = OverlayLayout.compute(count: 5, screen: screen, metrics: metrics)
        for slot in layout.slots {
            #expect(slot.width == layout.iconSide)
            #expect(slot.height == metrics.slotHeight(icon: layout.iconSide))
        }
    }

    @Test("the panel is the row plus its padding")
    func panelWrapsTheRow() {
        let layout = OverlayLayout.compute(count: 7, screen: screen, metrics: metrics)
        let padding = metrics.padding(icon: layout.iconSide)
        #expect(layout.size.height == layout.slots[0].height + padding * 2)
        #expect(layout.size.width == layout.slots[layout.visible - 1].maxX + padding)
    }

    @Test("a single application produces one slot")
    func singleApplication() {
        let layout = OverlayLayout.compute(count: 1, screen: screen, metrics: metrics)
        #expect(layout.slots.count == 1)
        #expect(layout.visible == 1)
        #expect(layout.slots[0].minX == metrics.padding(icon: layout.iconSide))
    }

    @Test("the name shrinks with the icon and never below the floor")
    func labelFollowsIcon() {
        let roomy = OverlayLayout.compute(count: 4, screen: screen, metrics: metrics)
        let crowded = OverlayLayout.compute(
            count: CarouselWindow.span,
            screen: CGSize(width: 700, height: 500),
            metrics: metrics
        )
        #expect(metrics.labelSize(icon: roomy.iconSide) == metrics.largestLabel)
        #expect(metrics.labelSize(icon: crowded.iconSide) < metrics.largestLabel)
        #expect(metrics.labelSize(icon: crowded.iconSide) >= metrics.smallestLabel)
    }

    @Test("no applications produce no layout")
    func noApplications() {
        #expect(OverlayLayout.compute(count: 0, screen: screen, metrics: metrics) == .empty)
    }

    @Test(
        "the ribbon matches the measured system switcher while both show the same row",
        arguments: [[3, 100, 30], [5, 100, 30], [10, 100, 30]]
    )
    func matchesTheSystemSwitcher(row: [Int]) {
        let layout = OverlayLayout.compute(
            count: row[0],
            screen: CGSize(width: 1728, height: 1117),
            metrics: metrics
        )
        #expect(layout.iconSide == CGFloat(row[1]))
        #expect(layout.slots[1].minX - layout.slots[0].maxX == CGFloat(row[2]))
    }

    @Test("slots never overlap on any screen", arguments: [1280.0, 1440.0, 1728.0, 2560.0])
    func slotsNeverOverlap(width: CGFloat) {
        let screen = CGSize(width: width, height: (width * 0.625).rounded())
        for count in 2...64 {
            let slots = OverlayLayout.compute(count: count, screen: screen, metrics: metrics).slots
            for (index, slot) in slots.enumerated().dropFirst() {
                #expect(slot.minX >= slots[index - 1].maxX)
            }
        }
    }

    @Test("the ribbon fits the width budget on any screen", arguments: [1280.0, 1440.0, 1728.0, 2560.0])
    func fitsTheBudget(width: CGFloat) {
        let screen = CGSize(width: width, height: (width * 0.625).rounded())
        for count in 1...64 {
            let layout = OverlayLayout.compute(count: count, screen: screen, metrics: metrics)
            #expect(layout.size.width <= (screen.width * metrics.widestShare).rounded() + 1)
            #expect(layout.iconSide >= metrics.tiniestIcon)
        }
    }
}
