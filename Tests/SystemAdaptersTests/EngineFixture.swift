import SwitcherCore

@testable import SystemAdapters

@MainActor
struct EngineFixture {
    let engine: InterceptingHotkeyEngine
    let log: RecordingLogSink
    let modes: Box<[HotkeyTapMode]>
    let engines: Box<[HotkeyEngineStub]>
}
