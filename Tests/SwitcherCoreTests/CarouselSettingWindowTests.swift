import Testing

@testable import SwitcherCore

@Suite("Carousel as the profile sets it")
struct CarouselSettingWindowTests {
    @Test("switched off, the ribbon shows everything and the selection moves")
    func stillRow() {
        let off = CarouselSetting(isEnabled: false)
        #expect(CarouselWindow.indices(count: 20, selection: 7, carousel: off) == Array(0..<20))
        #expect(CarouselWindow.place(of: 7, count: 20, carousel: off) == 7)
    }

    @Test("the number of slots is the width of the turning window", arguments: [5, 6, 8, 12])
    func windowIsAsWideAsAsked(slots: Int) {
        let carousel = CarouselSetting(slots: slots)
        let shown = CarouselWindow.indices(count: 40, selection: 20, carousel: carousel)
        #expect(shown.count == slots)
        #expect(shown[CarouselWindow.place(of: 20, count: 40, carousel: carousel)] == 20)
    }

    @Test("a short list is a plain row whatever the slots say")
    func shortListDoesNotTurn() {
        let carousel = CarouselSetting(slots: 12)
        #expect(CarouselWindow.indices(count: 3, selection: 2, carousel: carousel) == [0, 1, 2])
        #expect(CarouselWindow.place(of: 2, count: 3, carousel: carousel) == 2)
    }

    @Test("the selection keeps its slot while the entries turn under it")
    func selectionKeepsItsSlot() {
        let carousel = CarouselSetting(slots: 7)
        let place = CarouselWindow.place(of: 30, count: 60, carousel: carousel)
        for selection in [20, 21, 22, 40] {
            let shown = CarouselWindow.indices(count: 60, selection: selection, carousel: carousel)
            #expect(shown[place] == selection)
        }
    }
}
