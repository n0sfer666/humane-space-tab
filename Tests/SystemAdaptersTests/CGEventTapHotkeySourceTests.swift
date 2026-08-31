import SwitcherCore
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Event tap hotkey source")
struct CGEventTapHotkeySourceTests {
    private func makeSource(_ log: RecordingLogSink) -> CGEventTapHotkeySource {
        CGEventTapHotkeySource(
            shortcuts: .standard,
            mode: .observe,
            log: log,
            session: { nil },
            emit: { _ in }
        )
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
            shortcuts: .standard,
            mode: .observe,
            log: log,
            session: { .applications },
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
            shortcuts: .standard,
            mode: .observe,
            log: log,
            session: { nil },
            emit: { commands.append($0) }
        )
        #expect(source.swallows(TapEvent.disabled) == false)
        #expect(commands.isEmpty)
        #expect(log.events.contains(.hotkeyTapReenabled))
    }

    private func intercepting(
        opens: Bool,
        commands: Box<[HotkeyCommand]>
    ) -> CGEventTapHotkeySource {
        let open = Box(false)
        return CGEventTapHotkeySource(
            shortcuts: .standard,
            mode: .intercept,
            log: RecordingLogSink(),
            session: { open.value ? .frontWindows : nil },
            emit: { command in
                commands.value.append(command)
                if case .activate = command { open.value = opens }
            }
        )
    }

    private func stroke(_ key: KeyCode, _ modifiers: ModifierSet, _ phase: KeyPhase) -> TapEvent {
        .stroke(KeyStroke(key: key, modifiers: modifiers, phase: phase))
    }

    @Test("a shortcut that opens no session gives the key back to the system")
    func passesThroughWhenNothingOpens() {
        let commands = Box<[HotkeyCommand]>([])
        let source = intercepting(opens: false, commands: commands)
        #expect(source.swallows(stroke(.grave, [.command], .down)) == false)
        #expect(commands.value == [.activate(.forward, .frontWindows)])
        #expect(source.swallows(stroke(.grave, [.command], .up)) == false)
    }

    @Test("a shortcut that opens a session keeps the key")
    func swallowsWhenSessionOpens() {
        let commands = Box<[HotkeyCommand]>([])
        let source = intercepting(opens: true, commands: commands)
        #expect(source.swallows(stroke(.grave, [.command], .down)))
        #expect(commands.value == [.activate(.forward, .frontWindows)])
        #expect(source.swallows(stroke(.grave, [.command], .up)))
    }
}
