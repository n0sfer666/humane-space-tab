/// Whether the taps this process owns still carry key presses. macOS strips the key bits
/// from a tap's mask when Input Monitoring refuses the process, and tells the app nothing:
/// the tap stays alive, enabled and deaf. This reads the outcome, never the permission.
@MainActor
public protocol KeyEventDelivery: AnyObject {
    var deliversKeyEvents: Bool { get }
}
