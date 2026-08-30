import SwitcherCore
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Event tap shortcut recorder")
struct CGEventTapShortcutRecorderTests {
    @MainActor
    private final class Fixture {
        let outcomes = Box<[ShortcutRecordingOutcome]>([])
        var deferred: [@MainActor () -> Void] = []
        lazy var recorder = CGEventTapShortcutRecorder { [unowned self] work in self.deferred.append(work) }

        func start() {
            _ = recorder.start { [outcomes] in outcomes.value.append($0) }
        }

        func run() {
            let pending = deferred
            deferred = []
            for work in pending { work() }
        }

        func swallows(_ key: KeyCode, _ modifiers: ModifierSet, _ phase: KeyPhase) -> Bool {
            recorder.swallows(.stroke(KeyStroke(key: key, modifiers: modifiers, phase: phase)))
        }
    }

    @Test("a combination is delivered only once its release has been swallowed too")
    func recordsAfterRelease() {
        let fixture = Fixture()
        fixture.start()
        #expect(fixture.swallows(.tab, [.option], .down))
        #expect(fixture.outcomes.value.isEmpty)
        #expect(fixture.swallows(.tab, [.option], .up))
        #expect(fixture.outcomes.value.isEmpty)
        fixture.run()
        #expect(fixture.outcomes.value == [.recorded(Shortcut(key: .tab, modifiers: [.option]))])
    }

    @Test("the outcome never arrives inside the callback that captured it")
    func deliversOffTheCallback() {
        let fixture = Fixture()
        fixture.start()
        _ = fixture.swallows(.escape, [], .down)
        _ = fixture.swallows(.escape, [], .up)
        #expect(fixture.deferred.count == 1)
        fixture.run()
        #expect(fixture.outcomes.value == [.cancelled])
    }

    @Test("a refused combination is reported with its reason and keeps recording")
    func reportsRejection() {
        let fixture = Fixture()
        fixture.start()
        #expect(fixture.swallows(.tab, [.command, .shift], .down))
        #expect(fixture.outcomes.value == [.rejected(.containsShift)])
        #expect(fixture.deferred.isEmpty)
    }

    @Test("a modifier change is reported but passed on, so nothing is left stuck down")
    func passesModifierChanges() {
        let fixture = Fixture()
        fixture.start()
        #expect(fixture.swallows(KeyCode(rawValue: 55), [.command], .flagsChanged) == false)
        #expect(fixture.outcomes.value == [.incomplete])
    }

    @Test("a release whose press was never swallowed is passed on, so nothing is left held")
    func passesUnpairedRelease() {
        let fixture = Fixture()
        fixture.start()
        #expect(fixture.swallows(.tab, [.option], .up) == false)
        #expect(fixture.outcomes.value.isEmpty)
    }

    @Test("presses after the combination are swallowed but change nothing")
    func ignoresLaterPresses() {
        let fixture = Fixture()
        fixture.start()
        _ = fixture.swallows(.tab, [.option], .down)
        #expect(fixture.swallows(.space, [.option], .down))
        _ = fixture.swallows(.tab, [.option], .up)
        fixture.run()
        #expect(fixture.outcomes.value == [.recorded(Shortcut(key: .tab, modifiers: [.option]))])
    }

    @Test("stopping forgets the observer, so a late event reaches nobody")
    func stopForgetsObserver() {
        let fixture = Fixture()
        fixture.start()
        fixture.recorder.stop()
        _ = fixture.swallows(.tab, [.option], .down)
        _ = fixture.swallows(.tab, [.option], .up)
        fixture.run()
        #expect(fixture.outcomes.value.isEmpty)
    }
}
