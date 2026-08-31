import SwitcherCore
import SystemPorts
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Entry expansion")
struct EntryExpansionTests {
    private final class InventorySpy: SpaceInventorySource {
        var stack: [WindowIdentifier] = []
        var asked = 0

        func inventory() -> SpaceInventory {
            SpaceInventory(applications: [], layer: .onScreen)
        }

        func frontToBackApplications() -> [ProcessIdentifier] { [] }

        func frontToBackWindows() -> [WindowIdentifier] {
            asked += 1
            return stack
        }
    }

    private struct Preference: WindowSwitchingPreference {
        let switchesWindows: Bool
    }

    private func application(_ pid: Int32, windows: [UInt32]) -> SwitchableApplication {
        SwitchableApplication(
            pid: ProcessIdentifier(rawValue: pid),
            bundleIdentifier: "test.\(pid)",
            name: "App \(pid)",
            isActive: false,
            windows: windows.map { ApplicationWindow(id: WindowIdentifier(rawValue: $0), visibility: .onScreen) }
        )
    }

    @Test("with the preference off the ribbon lists applications and the system is not asked")
    func listsApplications() {
        let inventory = InventorySpy()
        let expansion = EntryExpansion(inventory: inventory, preference: Preference(switchesWindows: false))
        let entries = expansion.entries(
            [application(1, windows: [10, 11])],
            onCurrentSpace: [WindowIdentifier(rawValue: 10)]
        )
        #expect(entries.map(\.window) == [nil])
        #expect(inventory.asked == 0)
    }

    @Test("with the preference on every window of this Space is its own entry")
    func listsWindows() {
        let inventory = InventorySpy()
        inventory.stack = [11, 10].map(WindowIdentifier.init(rawValue:))
        let expansion = EntryExpansion(inventory: inventory, preference: Preference(switchesWindows: true))
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
        let expansion = EntryExpansion(inventory: inventory, preference: Preference(switchesWindows: false))
        let entries = expansion.cycle(
            [application(1, windows: [10, 11]), application(2, windows: [20])],
            onCurrentSpace: Set([10, 11, 20].map(WindowIdentifier.init(rawValue:)))
        )
        #expect(entries.map { $0.window?.id.rawValue } == [11, 10])
        #expect(entries.allSatisfy { $0.application.pid == ProcessIdentifier(rawValue: 1) })
        #expect(inventory.asked == 1)
    }
}
