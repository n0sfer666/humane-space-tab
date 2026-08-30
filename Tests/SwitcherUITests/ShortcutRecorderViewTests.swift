import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Shortcut recorder view")
struct ShortcutRecorderViewTests {
    @MainActor
    private final class Fixture {
        let source: ShortcutRecorderSourceStub
        var adopted: [Shortcut] = []
        var grants = 0
        lazy var view = ShortcutRecorderView(
            shortcut: .commandTab,
            formatter: ShortcutFormatter(naming: KeyNamingStub(names: [:])),
            source: source,
            requestGrant: { [unowned self] in self.grants += 1 },
            onChange: { [unowned self] in self.adopted.append($0) }
        )

        init(succeeds: Bool = true) {
            source = ShortcutRecorderSourceStub(succeeds: succeeds)
        }
    }

    @Test("a recorded shortcut is adopted once and ends the recording")
    func adoptsRecorded() {
        let fixture = Fixture()
        fixture.view.beginRecording()
        #expect(fixture.view.isRecording)
        let recorded = Shortcut(key: .space, modifiers: [.control, .option])
        fixture.source.send(.recorded(recorded))
        #expect(fixture.adopted == [recorded])
        #expect(fixture.view.isRecording == false)
        #expect(fixture.source.stops == 1)
    }

    @Test("a refused combination keeps the recorder listening")
    func keepsRecordingAfterRejection() {
        let fixture = Fixture()
        fixture.view.beginRecording()
        fixture.source.send(.rejected(.containsShift))
        fixture.source.send(.incomplete)
        #expect(fixture.view.isRecording)
        #expect(fixture.source.stops == 0)
        #expect(fixture.adopted.isEmpty)
    }

    @Test("Escape ends the recording and leaves the shortcut alone")
    func cancelChangesNothing() {
        let fixture = Fixture()
        fixture.view.beginRecording()
        fixture.source.send(.cancelled)
        #expect(fixture.view.isRecording == false)
        #expect(fixture.source.stops == 1)
        #expect(fixture.adopted.isEmpty)
    }

    @Test("recording the shortcut already in use changes nothing but still ends")
    func adoptsNothingTwice() {
        let fixture = Fixture()
        fixture.view.beginRecording()
        fixture.source.send(.recorded(.commandTab))
        #expect(fixture.adopted.isEmpty)
        #expect(fixture.view.isRecording == false)
        #expect(fixture.source.stops == 1)
    }

    @Test("ending a recording that never began touches nothing")
    func ignoresUnpairedEnd() {
        let fixture = Fixture()
        fixture.view.endRecording()
        #expect(fixture.source.stops == 0)
    }

    @Test("a recorder that cannot capture never claims to be recording")
    func reportsMissingPermission() {
        let fixture = Fixture(succeeds: false)
        fixture.view.beginRecording()
        #expect(fixture.view.isRecording == false)
        #expect(fixture.source.starts == 1)
    }
}
