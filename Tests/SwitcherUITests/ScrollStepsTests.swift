import Testing

@testable import SwitcherUI

@Suite("Scroll steps")
struct ScrollStepsTests {
    private let notch = ScrollSteps.threshold

    @Test("a scroll smaller than a notch moves nothing")
    func keepsSmallDeltas() {
        var steps = ScrollSteps()
        #expect(steps.steps(across: 0, down: notch / 3) == 0)
    }

    @Test("small scrolls in the same direction add up to one step")
    func accumulatesToOneStep() {
        var steps = ScrollSteps()
        #expect(steps.steps(across: 0, down: notch * 0.6) == 0)
        #expect(steps.steps(across: 0, down: notch * 0.6) == 1)
        #expect(steps.steps(across: 0, down: notch * 0.6) == 0)
    }

    @Test("a long scroll moves one entry per notch")
    func stepsOncePerNotch() {
        var steps = ScrollSteps()
        #expect(steps.steps(across: 0, down: notch * 3.5) == 3)
    }

    @Test("down and right move forward, up and left move backward")
    func followsTheDirection() {
        var steps = ScrollSteps()
        #expect(steps.steps(across: 0, down: notch) == 1)
        #expect(steps.steps(across: 0, down: -notch * 2) == -2)
        var sideways = ScrollSteps()
        #expect(sideways.steps(across: notch, down: 0) == 1)
        #expect(sideways.steps(across: -notch, down: 0) == -1)
    }

    @Test("the bigger of the two axes decides")
    func followsTheDominantAxis() {
        var steps = ScrollSteps()
        #expect(steps.steps(across: notch, down: -notch / 4) == 1)
        var vertical = ScrollSteps()
        #expect(vertical.steps(across: -notch / 4, down: notch) == 1)
    }

    @Test("a scroll that turns around does not carry the old direction")
    func forgetsTheOppositeDirection() {
        var steps = ScrollSteps()
        #expect(steps.steps(across: 0, down: notch * 0.9) == 0)
        #expect(steps.steps(across: 0, down: -notch * 0.9) == 0)
        #expect(steps.steps(across: 0, down: -notch * 0.9) == -1)
    }
}
