import SwitcherCore

public protocol ProcessHierarchy: Sendable {
    func parent(of process: ProcessIdentifier) -> ProcessIdentifier?
    func executablePath(of process: ProcessIdentifier) -> String?
}
