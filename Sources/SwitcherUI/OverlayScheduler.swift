import Foundation

@MainActor
public protocol OverlayScheduler: AnyObject {
    /// Runs the work unless `cancel()` arrives first.
    func schedule(after delay: TimeInterval, _ work: @escaping @MainActor () -> Void)
    func cancel()
}
