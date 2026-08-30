import SwitcherCore

@MainActor
public protocol HotkeyEngine: Sendable {
    func start() -> HotkeyEngineStatus
    func stop()
}
