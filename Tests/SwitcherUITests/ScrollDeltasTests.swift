import AppKit
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Scroll deltas")
struct ScrollDeltasTests {
    private func wheel(_ amount: Int32) -> NSEvent? {
        CGEvent(
            scrollWheelEvent2Source: nil,
            units: .line,
            wheelCount: 1,
            wheel1: amount,
            wheel2: 0,
            wheel3: 0
        ).flatMap(NSEvent.init(cgEvent:))
    }

    @Test("a notch away from the user steps backward, one notch at a time")
    func wheelUpIsBackward() throws {
        let event = try #require(wheel(1))
        let deltas = ScrollDeltas.of(event)
        #expect(deltas.down == -ScrollSteps.threshold)
    }

    @Test("a notch towards the user steps forward")
    func wheelDownIsForward() throws {
        let event = try #require(wheel(-1))
        #expect(ScrollDeltas.of(event).down == ScrollSteps.threshold)
    }
}
