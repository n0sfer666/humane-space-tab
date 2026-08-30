import Foundation

@MainActor
public final class MainQueueOverlayScheduler: OverlayScheduler {
    private var pending: DispatchWorkItem?

    public init() {}

    public func schedule(after delay: TimeInterval, _ work: @escaping @MainActor () -> Void) {
        cancel()
        let item = DispatchWorkItem { [weak self] in
            MainActor.assumeIsolated {
                self?.pending = nil
                work()
            }
        }
        pending = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    public func cancel() {
        pending?.cancel()
        pending = nil
    }
}
