import SwitcherCore
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Intercepting hotkey engine")
struct InterceptingHotkeyEngineTests {
    private func make(statuses: [HotkeyTapMode: HotkeyEngineStatus]) -> EngineFixture {
        let log = RecordingLogSink()
        let modes = Box<[HotkeyTapMode]>([])
        let engines = Box<[HotkeyEngineStub]>([])
        let engine = InterceptingHotkeyEngine(log: log) { mode in
            modes.value.append(mode)
            let stub = HotkeyEngineStub(status: statuses[mode] ?? .unavailable)
            engines.value.append(stub)
            return stub
        }
        return EngineFixture(engine: engine, log: log, modes: modes, engines: engines)
    }

    @Test("interception is preferred when the tap can be created")
    func prefersInterception() {
        let fixture = make(statuses: [.intercept: .running, .observe: .running])
        #expect(fixture.engine.start() == .running)
        #expect(fixture.modes.value == [.intercept])
        #expect(!fixture.log.events.contains(.hotkeyInterceptUnavailable))
    }

    @Test("a refused interception falls back to observation and says so")
    func fallsBackToObservation() {
        let fixture = make(statuses: [.intercept: .unavailable, .observe: .running])
        #expect(fixture.engine.start() == .running)
        #expect(fixture.modes.value == [.intercept, .observe])
        #expect(fixture.log.events.contains(.hotkeyInterceptUnavailable))
    }

    @Test("both modes refused leaves the engine unavailable")
    func bothRefused() {
        let fixture = make(statuses: [:])
        #expect(fixture.engine.start() == .unavailable)
        #expect(fixture.modes.value == [.intercept, .observe])
    }

    @Test("a second start reuses the engine already running")
    func secondStartReuses() {
        let fixture = make(statuses: [.intercept: .running])
        _ = fixture.engine.start()
        _ = fixture.engine.start()
        #expect(fixture.modes.value == [.intercept])
        #expect(fixture.engines.value.first?.starts == 2)
    }

    @Test("stopping stops the running engine and forgets it")
    func stopForgets() {
        let fixture = make(statuses: [.intercept: .running])
        _ = fixture.engine.start()
        fixture.engine.stop()
        _ = fixture.engine.start()
        #expect(fixture.engines.value.first?.stops == 1)
        #expect(fixture.modes.value == [.intercept, .intercept])
    }

    @Test("a refused engine is stopped instead of being left behind")
    func refusedEnginesAreStopped() {
        let fixture = make(statuses: [.observe: .running])
        _ = fixture.engine.start()
        #expect(fixture.engines.value.first?.stops == 1)
        #expect(fixture.engines.value.last?.stops == 0)
    }

    @Test("both modes refused leaves nothing running")
    func bothRefusedStopEverything() {
        let fixture = make(statuses: [:])
        _ = fixture.engine.start()
        #expect(fixture.engines.value.map(\.stops) == [1, 1])
    }
}
