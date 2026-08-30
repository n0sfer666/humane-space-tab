import SwitcherCore
import SystemPorts

@MainActor
final class HotkeyEngineStub: HotkeyEngine {
    private let status: HotkeyEngineStatus
    private(set) var starts = 0
    private(set) var stops = 0

    init(status: HotkeyEngineStatus) {
        self.status = status
    }

    func start() -> HotkeyEngineStatus {
        starts += 1
        return status
    }

    func stop() { stops += 1 }
}
