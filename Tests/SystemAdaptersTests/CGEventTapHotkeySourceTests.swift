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

    @Test("a re-armed tap cancels the session it may have lost the release of")
    func reenableCancelsOpenSession() {
        let log = RecordingLogSink()
        var commands: [HotkeyCommand] = []
        let source = CGEventTapHotkeySource(
            mode: .observe,
            log: log,
            sessionOpen: { true },
            emit: { commands.append($0) }
        )
        #expect(source.swallows(TapEvent.disabled) == false)
        #expect(commands == [.cancel])
        #expect(log.events.contains(.hotkeyTapReenabled))
    }

    @Test("a re-armed tap cancels nothing when no session is open")
    func reenableKeepsQuietWithoutSession() {
        let log = RecordingLogSink()
        var commands: [HotkeyCommand] = []
        let source = CGEventTapHotkeySource(
            mode: .observe,
            log: log,
            sessionOpen: { false },
            emit: { commands.append($0) }
        )
        #expect(source.swallows(TapEvent.disabled) == false)
        #expect(commands.isEmpty)
        #expect(log.events.contains(.hotkeyTapReenabled))
    }
}
