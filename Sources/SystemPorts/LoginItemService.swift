import SwitcherCore

@MainActor
public protocol LoginItemService: AnyObject {
    /// The system is the only source of truth: the user can revoke a login item without
    /// ever opening our window.
    var status: LoginItemStatus { get }
    func register() throws
    func unregister() throws
}
