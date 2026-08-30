import SwitcherCore

@MainActor
public protocol ApplicationActivator: Sendable {
    /// Raises the application, unhiding it when needed; false when the process is gone or refuses.
    func activate(_ process: ProcessIdentifier) -> Bool
}
