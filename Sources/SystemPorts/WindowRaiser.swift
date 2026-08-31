import SwitcherCore

@MainActor
public protocol WindowRaiser: Sendable {
    /// Brings one window of the process to the front of that application, un-minimising it
    /// first; false when the window cannot be told apart from another or refuses to move.
    func raise(_ window: WindowIdentifier, of process: ProcessIdentifier) -> Bool
}
