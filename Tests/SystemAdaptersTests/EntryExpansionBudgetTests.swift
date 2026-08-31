import SwitcherCore
import SystemPorts
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Entry expansion budget")
struct EntryExpansionBudgetTests {
    @Test("an application whose windows are all elsewhere is never asked about them")
    func skipsApplicationsWithNoCandidate() {
        let inventory = InventorySpy()
        let log = RecordingLogSink()
        let clock = SteppingClock()
        let identity = IdentitySpy(named: [10])
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: Preference(switchesWindows: true),
            identity: identity,
            log: log,
            now: clock.now
        )
        let entries = expansion.entries([application(1, windows: [10])], onCurrentSpace: [])
        #expect(entries.map(\.window) == [nil])
        #expect(identity.asked.isEmpty)
    }

    @Test("the budget stops the pass instead of spending the gesture on wedged applications")
    func theBudgetEndsThePass() {
        let inventory = InventorySpy()
        inventory.stack = [10, 20].map(WindowIdentifier.init(rawValue:))
        let log = RecordingLogSink()
        let clock = SteppingClock()
        clock.step = EntryExpansion.budget / 2
        let identity = IdentitySpy(named: [10, 20])
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: Preference(switchesWindows: true),
            identity: identity,
            log: log,
            now: clock.now
        )
        let entries = expansion.entries(
            [application(1, windows: [10]), application(2, windows: [20])],
            onCurrentSpace: Set([10, 20].map(WindowIdentifier.init(rawValue:)))
        )
        #expect(identity.asked == [ProcessIdentifier(rawValue: 1)])
        #expect(entries.map { $0.window?.id.rawValue } == [10, nil])
    }

    @Test("losing the window list is said once, not once per gesture")
    func reportsTheLossOnce() {
        let inventory = InventorySpy()
        let log = RecordingLogSink()
        let clock = SteppingClock()
        let identity = IdentitySpy(named: [])
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: Preference(switchesWindows: true),
            identity: identity,
            log: log,
            now: clock.now
        )
        let applications = [application(1, windows: [10])]
        let space = Set([10].map(WindowIdentifier.init(rawValue:)))
        _ = expansion.entries(applications, onCurrentSpace: space)
        _ = expansion.entries(applications, onCurrentSpace: space)
        #expect(log.events == [.windowListUnanswered])
    }

    @Test("a system that names no window behind an element is reported as that, not as silence")
    func reportsAMissingSymbol() {
        let inventory = InventorySpy()
        let log = RecordingLogSink()
        let clock = SteppingClock()
        let identity = IdentitySpy(named: [])
        identity.canIdentifyWindows = false
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: Preference(switchesWindows: true),
            identity: identity,
            log: log,
            now: clock.now
        )
        _ = expansion.entries(
            [application(1, windows: [10])],
            onCurrentSpace: Set([10].map(WindowIdentifier.init(rawValue:)))
        )
        #expect(log.events == [.windowListUnavailable])
    }
}
