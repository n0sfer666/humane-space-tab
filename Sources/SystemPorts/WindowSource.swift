import SwitcherCore

@MainActor
public protocol WindowSource: Sendable {
    /// Every real window, including minimised and hidden ones, in no particular order.
    func windows() -> [WindowInfo]

    /// The windows visible right now, front to back.
    func onScreenWindows() -> [WindowInfo]
}
