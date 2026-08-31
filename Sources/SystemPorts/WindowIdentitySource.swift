import SwitcherCore

@MainActor
public protocol WindowIdentitySource: Sendable {
    /// Which of the candidates the application names as its own windows. An empty answer
    /// means it named none of them — the window server's list for that process is then not
    /// split into entries, because nothing confirms any of it is a window.
    func windows(of process: ProcessIdentifier, among candidates: Set<WindowIdentifier>) -> Set<WindowIdentifier>

    /// False when the system no longer offers the symbol that links an element to a window.
    var canIdentifyWindows: Bool { get }
}
