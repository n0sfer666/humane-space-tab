import Testing

@testable import SwitcherCore

@Suite("Carousel window")
struct CarouselWindowTests {
    @Test("a list that fits is shown whole, where it is")
    func shortListsAreNotWindowed() {
        #expect(CarouselWindow.indices(count: 3, selection: 2) == [0, 1, 2])
        #expect(CarouselWindow.place(of: 2, count: 3) == 2)
        #expect(CarouselWindow.indices(count: 10, selection: 9).count == 10)
        #expect(CarouselWindow.place(of: 9, count: 10) == 9)
    }

    @Test("an empty list has no window")
    func emptyListsAreEmpty() {
        #expect(CarouselWindow.indices(count: 0, selection: 0).isEmpty)
    }

    @Test("past ten entries the selection keeps its place and the list moves under it")
    func longListsWindow() {
        #expect(CarouselWindow.indices(count: 20, selection: 7) == Array(3...12))
        #expect(CarouselWindow.place(of: 7, count: 20) == CarouselWindow.before)
        #expect(CarouselWindow.indices(count: 20, selection: 7)[CarouselWindow.before] == 7)
    }

    @Test("the window wraps at both ends, so the ribbon never runs out of icons")
    func theWindowWraps() {
        #expect(CarouselWindow.indices(count: 20, selection: 0) == [16, 17, 18, 19, 0, 1, 2, 3, 4, 5])
        #expect(CarouselWindow.indices(count: 20, selection: 19) == [15, 16, 17, 18, 19, 0, 1, 2, 3, 4])
    }

    @Test("the window is always as wide as it can be")
    func theWindowIsFull() {
        for selection in 0..<40 {
            let indices = CarouselWindow.indices(count: 40, selection: selection)
            #expect(indices.count == CarouselWindow.span)
            #expect(Set(indices).count == CarouselWindow.span)
        }
    }
}
