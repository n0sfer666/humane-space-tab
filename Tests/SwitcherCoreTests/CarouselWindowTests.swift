import Testing

@testable import SwitcherCore

@Suite("Carousel window")
struct CarouselWindowTests {
    @Test("a list that fits turns under the selection instead of standing still")
    func shortListsTurn() {
        #expect(CarouselWindow.indices(count: 3, selection: 2) == [1, 2, 0])
        #expect(CarouselWindow.place(of: 2, count: 3) == 1)
        #expect(CarouselWindow.indices(count: 5, selection: 2) == [0, 1, 2, 3, 4])
        #expect(CarouselWindow.indices(count: 5, selection: 3) == [1, 2, 3, 4, 0])
    }

    @Test("a list that fits shows every entry once and no entry twice")
    func shortListsNeverRepeat() {
        for count in 1...CarouselWindow.span {
            for selection in 0..<count {
                let indices = CarouselWindow.indices(count: count, selection: selection)
                #expect(indices.count == count)
                #expect(Set(indices).count == count)
                #expect(indices[CarouselWindow.place(of: selection, count: count)] == selection)
            }
        }
    }

    @Test("two applications put the selection first, with the other beside it")
    func twoApplications() {
        #expect(CarouselWindow.indices(count: 2, selection: 0) == [0, 1])
        #expect(CarouselWindow.indices(count: 2, selection: 1) == [1, 0])
        #expect(CarouselWindow.place(of: 1, count: 2) == 0)
    }

    @Test("an empty list has no window")
    func emptyListsAreEmpty() {
        #expect(CarouselWindow.indices(count: 0, selection: 0).isEmpty)
    }

    @Test("the selection's place grows with the list until the ribbon is full")
    func thePlaceGrowsWithTheList() {
        let places = (1...CarouselWindow.span).map { CarouselWindow.place(of: 0, count: $0) }
        #expect(places == [0, 0, 1, 1, 2, 2, 3, 3, 4, 4])
        #expect(CarouselWindow.place(of: 0, count: CarouselWindow.span + 1) == CarouselWindow.before)
    }

    @Test("past a full ribbon the selection keeps its place and the list moves under it")
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
