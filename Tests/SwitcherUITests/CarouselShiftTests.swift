import SwitcherCore
import Testing

@testable import SwitcherUI

@Suite("Carousel shift")
struct CarouselShiftTests {
    private func window(_ selection: Int, count: Int = 20) -> [Int] {
        CarouselWindow.indices(count: count, selection: selection)
    }

    @Test("a step forward moves the ribbon one slot")
    func stepsForward() {
        #expect(CarouselShift.between(window(5), window(6)) == 1)
    }

    @Test("a step back moves it the other way")
    func stepsBack() {
        #expect(CarouselShift.between(window(6), window(5)) == -1)
    }

    @Test("a step across the seam moves like any other")
    func wrapsLikeAnyOtherStep() {
        #expect(CarouselShift.between(window(19), window(0)) == 1)
        #expect(CarouselShift.between(window(0), window(19)) == -1)
    }

    @Test("a ribbon that did not move is not slid")
    func standingStill() {
        #expect(CarouselShift.between(window(5), window(5)) == 0)
        #expect(CarouselShift.between([0, 1, 2], [0, 1, 2]) == 0)
    }

    @Test("a jump of several slots lands rather than slides")
    func jumpsAreNotAnimated() {
        #expect(CarouselShift.between(window(5), window(9)) == 0)
    }

    @Test("a ribbon that changed shape is not slid")
    func changedShape() {
        #expect(CarouselShift.between([], window(5)) == 0)
        #expect(CarouselShift.between([1], [2]) == 0)
        #expect(CarouselShift.between(window(5), window(5, count: 12)) == 0)
    }

    @Test("a ribbon of five slides too, its own entries turning under the selection")
    func turningRibbonsSlide() {
        #expect(CarouselShift.between(window(1, count: 5), window(2, count: 5)) == 1)
        #expect(CarouselShift.between(window(2, count: 5), window(1, count: 5)) == -1)
    }

    @Test("a ribbon too short to turn holds still while the selection moves along it")
    func ribbonsBelowFiveDoNotSlide() {
        #expect(CarouselShift.between(window(1, count: 4), window(2, count: 4)) == 0)
        #expect(CarouselShift.between(window(0, count: 2), window(1, count: 2)) == 0)
    }
}
