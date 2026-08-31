import SwitcherCore

@MainActor
public protocol WindowTitleSource: Sendable {
    /// Titles of the named windows of one process. A window whose element cannot be
    /// identified is absent rather than guessed, and the call never runs on the tap's
    /// critical path: it is synchronous IPC into another application.
    func titles(of process: ProcessIdentifier, windows: [WindowIdentifier]) -> [WindowIdentifier: String]
}
