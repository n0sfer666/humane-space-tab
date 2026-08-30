import SwitcherCore

@MainActor
public protocol ApplicationActivationObserver: Sendable {
    /// Replaces any previous handler; every activation of a running application is delivered on the main actor.
    func observe(_ handler: @escaping @MainActor (ProcessIdentifier) -> Void)

    /// Stops delivery; safe to call when nothing is observed.
    func stop()
}
