import CoreGraphics
import SwitcherCore
import Testing

@testable import SystemAdapters

@Suite("Window frame match")
struct WindowFrameMatchTests {
    private func frame(_ left: CGFloat, _ top: CGFloat, _ width: CGFloat = 800, _ height: CGFloat = 600) -> CGRect {
        CGRect(x: left, y: top, width: width, height: height)
    }

    private func pair(
        _ windows: [(id: UInt32, frame: CGRect)],
        _ elements: [(element: Int, frame: CGRect)]
    ) -> [WindowIdentifier: Int] {
        WindowFrameMatch.pair(
            windows: windows.map { (WindowIdentifier(rawValue: $0.id), $0.frame) },
            elements: elements
        )
    }

    @Test("one window and one element of the same frame are paired")
    func pairsSingleFrame() {
        #expect(pair([(10, frame(0, 0))], [(7, frame(0, 0))]) == [WindowIdentifier(rawValue: 10): 7])
    }

    @Test("windows are paired by frame, not by their order in the list")
    func pairsByFrame() {
        let paired = pair(
            [(10, frame(0, 0)), (11, frame(100, 100))],
            [(7, frame(100, 100)), (8, frame(0, 0))]
        )
        #expect(paired == [WindowIdentifier(rawValue: 10): 8, WindowIdentifier(rawValue: 11): 7])
    }

    @Test("a frame off by less than a pixel still pairs")
    func toleratesRounding() {
        #expect(pair([(10, frame(0.4, 0))], [(7, frame(0, 0.3))]) == [WindowIdentifier(rawValue: 10): 7])
    }

    @Test("two windows sharing a frame are paired by their order")
    func pairsIdenticalFramesByOrder() {
        let paired = pair(
            [(10, frame(0, 0)), (11, frame(0, 0))],
            [(7, frame(0, 0)), (8, frame(0, 0))]
        )
        #expect(paired == [WindowIdentifier(rawValue: 10): 7, WindowIdentifier(rawValue: 11): 8])
    }

    @Test("a frame with more windows than elements pairs neither")
    func dropsAmbiguousFrames() {
        #expect(pair([(10, frame(0, 0)), (11, frame(0, 0))], [(7, frame(0, 0))]).isEmpty)
    }

    @Test("a window no element matches is absent")
    func dropsUnmatchedWindows() {
        #expect(pair([(10, frame(0, 0))], [(7, frame(500, 500))]).isEmpty)
    }

    @Test("an element no window matches pairs nothing")
    func ignoresExtraElements() {
        #expect(pair([], [(7, frame(0, 0))]).isEmpty)
    }
}
