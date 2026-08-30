import SwitcherCore
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Event tap hotkey source")
struct CGEventTapHotkeySourceTests {
    private func makeSource(_ log: RecordingLogSink) -> CGEventTapHotkeySource {
        CGEventTapHotkeySource(mode: .observe, log: log, sessionOpen: { false }, emit: { _ in })
    }

    @Test("stopping without starting changes nothing")
    func stopWithoutStart() {
        let log = RecordingLogSink()
        makeSource(log).stop()
        #expect(log.events.isEmpty)
    }

    @Test("starting twice keeps one tap and reports it once")
    func startIsIdempotent() {
        let log = RecordingLogSink()
        let source = makeSource(log)
        let first = source.start()
        let second = source.start()
        #expect(first == second)
        #expect(log.events.filter { $0 == .hotkeyTapStarted }.count <= 1)
        #expect(log.events.filter { $0 == .hotkeyTapUnavailable }.count == (first == .running ? 0 : 2))
        source.stop()
    }

    @Test("a started tap is stopped once and can be started again")
    func stopIsIdempotentAndRestartable() {
        let log = RecordingLogSink()
        let source = makeSource(log)
        guard source.start() == .running else { return }
        source.stop()
        source.stop()
        #expect(log.events.filter { $0 == .hotkeyTapStopped }.count == 1)
        #expect(source.start() == .running)
        #expect(log.events.filter { $0 == .hotkeyTapStarted }.count == 2)
        source.stop()
    }
}
