import Testing

@testable import SwitcherUI

@Suite("Ribbon scroll")
struct RibbonScrollTests {
    @Test("a ribbon that shows everything never scrolls")
    func nothingToScroll() {
        var scroll = RibbonScroll()
        for selection in 0..<10 {
            #expect(scroll.settle(selection: selection, count: 10, visible: 10) == 0)
        }
    }

    @Test("the ribbon stays put while the selection is inside the window")
    func staysPutInsideTheWindow() {
        var scroll = RibbonScroll()
        for selection in 0..<25 {
            #expect(scroll.settle(selection: selection, count: 40, visible: 25) == 0)
        }
    }

    @Test("stepping past the trailing edge scrolls by one")
    func stepsForwardByOne() {
        var scroll = RibbonScroll()
        #expect(scroll.settle(selection: 25, count: 40, visible: 25) == 1)
        #expect(scroll.settle(selection: 26, count: 40, visible: 25) == 2)
    }

    @Test("stepping back past the leading edge scrolls back by one")
    func stepsBackByOne() {
        var scroll = RibbonScroll()
        scroll.settle(selection: 30, count: 40, visible: 25)
        #expect(scroll.offset == 6)
        #expect(scroll.settle(selection: 5, count: 40, visible: 25) == 5)
    }

    @Test("wrapping to the first application brings the ribbon home")
    func wrappingComesHome() {
        var scroll = RibbonScroll()
        scroll.settle(selection: 39, count: 40, visible: 25)
        #expect(scroll.offset == 15)
        #expect(scroll.settle(selection: 0, count: 40, visible: 25) == 0)
    }

    @Test("the offset never leaves the last window hanging past the end")
    func neverScrollsPastTheEnd() {
        var scroll = RibbonScroll()
        for selection in 0..<40 {
            let offset = scroll.settle(selection: selection, count: 40, visible: 25)
            #expect(offset >= 0)
            #expect(offset <= 15)
            #expect(selection >= offset)
            #expect(selection < offset + 25)
        }
    }

    @Test("a shorter ribbon pulls a stale offset back into range")
    func shrinkingClampsTheOffset() {
        var scroll = RibbonScroll()
        scroll.settle(selection: 39, count: 40, visible: 25)
        #expect(scroll.settle(selection: 0, count: 26, visible: 25) == 0)
    }

    @Test("a new session starts at the beginning")
    func resetStartsOver() {
        var scroll = RibbonScroll()
        scroll.settle(selection: 39, count: 40, visible: 25)
        scroll.reset()
        #expect(scroll.offset == 0)
    }

    @Test("an empty ribbon has no offset")
    func emptyRibbon() {
        var scroll = RibbonScroll()
        #expect(scroll.settle(selection: 0, count: 0, visible: 0) == 0)
    }
}
