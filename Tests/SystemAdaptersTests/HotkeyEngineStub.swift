import SwitcherCore
import SystemPorts

@MainActor
final class HotkeyEngineStub: HotkeyEngine {
    private let status: HotkeyEngineStatus
    private(set) var starts = 0
    private(set) var stops = 0
    private(set) var tap: HotkeyTapMode?

    init(status: HotkeyEngineStatus, tap: HotkeyTapMode? = nil) {
        self.status = status
        self.tap = tap
    }

    func start() -> HotkeyEngineStatus {
        starts += 1
        return status
    }

    func stop() { stops += 1 }
}
