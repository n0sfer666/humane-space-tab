import SwitcherCore

/// What macOS says about secure input at this moment. There is nothing to observe: the
/// window server announces neither the start nor the end of a hold, so the state is asked
/// for rather than awaited.
@MainActor
public protocol SecureInputMonitor: AnyObject {
    var holder: SecureInputHolder? { get }
}
