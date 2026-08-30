import SwitcherCore

/// Main-actor-bound because the only implementation asks HIToolbox for the current
/// keyboard layout, and that aborts when it is called off the main thread.
@MainActor
public protocol KeyNaming {
    /// The label the current keyboard layout prints on this key, or `nil` when the layout
    /// cannot say — a key code is a physical position, not a character.
    func name(for key: KeyCode) -> String?
}
