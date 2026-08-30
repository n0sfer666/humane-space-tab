import SwitcherCore
import SystemPorts

@MainActor
final class HotkeyEngineStub: HotkeyEngine {
    var tapWhenTrusted: HotkeyTapMode?
    var starts = 0
    var stops = 0
    private(set) var tap: HotkeyTapMode?

    func start() -> HotkeyEngineStatus {
        starts += 1
        tap = tapWhenTrusted
        return tap == nil ? .unavailable : .running
    }

    func stop() {
        stops += 1
        tap = nil
    }
}
