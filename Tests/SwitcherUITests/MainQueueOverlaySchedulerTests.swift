import Foundation
import SwitcherUI
import Testing

@MainActor
@Suite("Main queue overlay scheduler")
struct MainQueueOverlaySchedulerTests {
    @Test("scheduled work runs on the main actor once the delay elapses")
    func runsAfterTheDelay() async {
        let scheduler = MainQueueOverlayScheduler()
        await confirmation("work ran") { ran in
            scheduler.schedule(after: 0.01) { ran() }
            try? await Task.sleep(for: .milliseconds(120))
        }
    }

    @Test("cancelled work never runs")
    func cancelledWorkNeverRuns() async {
        let scheduler = MainQueueOverlayScheduler()
        await confirmation("work ran", expectedCount: 0) { ran in
            scheduler.schedule(after: 0.05) { ran() }
            scheduler.cancel()
            try? await Task.sleep(for: .milliseconds(120))
        }
    }

    @Test("scheduling again replaces the work still waiting")
    func schedulingReplacesTheWaitingWork() async {
        let scheduler = MainQueueOverlayScheduler()
        await confirmation("work ran", expectedCount: 1) { ran in
            scheduler.schedule(after: 0.05) { ran() }
            scheduler.schedule(after: 0.06) { ran() }
            try? await Task.sleep(for: .milliseconds(160))
        }
    }
}
