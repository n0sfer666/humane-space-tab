import SwitcherCore
import SystemPorts
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Entry expansion")
struct EntryExpansionTests {
    @Test("with the preference off the ribbon lists applications and the system is not asked")
    func listsApplications() {
        let inventory = InventorySpy()
        let log = RecordingLogSink()
        let clock = SteppingClock()
        let identity = IdentitySpy(named: [10, 11])
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: Preference(switchesWindows: false),
            identity: identity,
            log: log,
            now: clock.now
        )
        let entries = expansion.entries(
            [application(1, windows: [10, 11])],
            onCurrentSpace: [WindowIdentifier(rawValue: 10)]
        )
        #expect(entries.map(\.window) == [nil])
        #expect(inventory.asked == 0)
        #expect(identity.asked.isEmpty)
    }

    @Test("with the preference on every window of this Space is its own entry")
    func listsWindows() {
        let inventory = InventorySpy()
        inventory.stack = [11, 10].map(WindowIdentifier.init(rawValue:))
        let log = RecordingLogSink()
        let clock = SteppingClock()
        let identity = IdentitySpy(named: [10, 11])
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: Preference(switchesWindows: true),
            identity: identity,
            log: log,
            now: clock.now
        )
        let entries = expansion.entries(
            [application(1, windows: [10, 11])],
            onCurrentSpace: Set([10, 11].map(WindowIdentifier.init(rawValue:)))
        )
        #expect(entries.map { $0.window?.id.rawValue } == [11, 10])
        #expect(inventory.asked == 1)
    }

    @Test("the window cycle lists the front application's windows whatever the preference says")
    func cyclesFrontWindows() {
        let inventory = InventorySpy()
        inventory.stack = [11, 10].map(WindowIdentifier.init(rawValue:))
        let log = RecordingLogSink()
        let clock = SteppingClock()
        let identity = IdentitySpy(named: [10, 11])
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: Preference(switchesWindows: false),
            identity: identity,
            log: log,
            now: clock.now
        )
        let entries = expansion.cycle(
            [application(1, windows: [10, 11]), application(2, windows: [20])],
            onCurrentSpace: Set([10, 11, 20].map(WindowIdentifier.init(rawValue:)))
        )
        #expect(entries.map { $0.window?.id.rawValue } == [11, 10])
        #expect(entries.allSatisfy { $0.application.pid == ProcessIdentifier(rawValue: 1) })
        #expect(inventory.asked == 1)
    }

    @Test("a window the application does not name is not an entry, whatever the window server says")
    func dropsWindowsTheApplicationDoesNotName() {
        let inventory = InventorySpy()
        inventory.stack = [11].map(WindowIdentifier.init(rawValue:))
        let log = RecordingLogSink()
        let clock = SteppingClock()
        let identity = IdentitySpy(named: [11])
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: Preference(switchesWindows: true),
            identity: identity,
            log: log,
            now: clock.now
        )
        let entries = expansion.entries(
            [application(1, windows: [10, 11, 12])],
            onCurrentSpace: Set([10, 11, 12].map(WindowIdentifier.init(rawValue:)))
        )
        #expect(entries.map { $0.window?.id.rawValue } == [11])
        #expect(identity.asked == [ProcessIdentifier(rawValue: 1)])
    }

    @Test("an application that names no window stays one entry instead of splitting into phantoms")
    func keepsTheApplicationWhenItNamesNothing() {
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
        let entries = expansion.entries(
            [application(1, windows: [10, 11])],
            onCurrentSpace: Set([10, 11].map(WindowIdentifier.init(rawValue:)))
        )
        #expect(entries.map(\.window) == [nil])
    }

    @Test("the window cycle drops the window server's phantoms too")
    func cycleDropsPhantoms() {
        let inventory = InventorySpy()
        inventory.stack = [11, 10].map(WindowIdentifier.init(rawValue:))
        let log = RecordingLogSink()
        let clock = SteppingClock()
        let identity = IdentitySpy(named: [10])
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: Preference(switchesWindows: false),
            identity: identity,
            log: log,
            now: clock.now
        )
        let entries = expansion.cycle(
            [application(1, windows: [10, 11])],
            onCurrentSpace: Set([10, 11].map(WindowIdentifier.init(rawValue:)))
        )
        #expect(entries.map { $0.window?.id.rawValue } == [10])
    }
}
