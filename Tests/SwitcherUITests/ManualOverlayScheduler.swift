import Foundation
import SwitcherUI

@MainActor
final class ManualOverlayScheduler: OverlayScheduler {
    private(set) var delays: [TimeInterval] = []
    private var work: (@MainActor () -> Void)?

    func schedule(after delay: TimeInterval, _ work: @escaping @MainActor () -> Void) {
        delays.append(delay)
        self.work = work
    }

    func cancel() { work = nil }

    func fire() {
        let pending = work
        work = nil
        pending?()
    }
}
