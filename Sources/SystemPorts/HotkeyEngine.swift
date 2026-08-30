import SwitcherCore

@MainActor
public protocol HotkeyEngine: Sendable {
    /// Which tap is live, so callers can tell a switcher that works from one that only
    /// watches. `nil` means no tap at all.
    var tap: HotkeyTapMode? { get }
    func start() -> HotkeyEngineStatus
    func stop()
}
