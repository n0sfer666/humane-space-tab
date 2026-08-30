import Testing

@testable import SwitcherCore

@Suite("Inventory summary")
struct InventorySummaryTests {
    private func application(
        _ name: String,
        pid: Int32 = 2,
        windows: [WindowVisibility] = []
    ) -> SwitchableApplication {
        SwitchableApplication(
            pid: ProcessIdentifier(rawValue: pid),
            bundleIdentifier: "test.\(pid)",
            name: name,
            isActive: false,
            windows: windows.enumerated().map {
                ApplicationWindow(id: WindowIdentifier(rawValue: UInt32($0.offset)), visibility: $0.element)
            }
        )
    }

    @Test("an empty inventory says so instead of producing a blank text")
    func emptyInventory() {
        #expect(InventorySummary.text(for: []) == "No switchable applications.")
    }

    @Test("each application is one line with its window counts by visibility")
    func lineFormat() {
        let text = InventorySummary.text(for: [application("Notes", windows: [.onScreen, .minimised])])
        #expect(text == "Notes — 2 windows: 1 on screen, 1 minimised")
    }

    @Test("an application with no windows says it has none")
    func windowlessApplication() {
        #expect(InventorySummary.text(for: [application("Notes")]) == "Notes — no windows")
    }

    @Test("hidden windows are reported separately from minimised ones")
    func hiddenWindows() {
        let text = InventorySummary.text(for: [application("Mail", windows: [.hiddenApplication])])
        #expect(text == "Mail — 1 window: 1 hidden")
    }

    @Test("applications are listed one per line in the order given")
    func oneLinePerApplication() {
        let text = InventorySummary.text(for: [application("Alpha", pid: 2), application("Beta", pid: 3)])
        #expect(text.split(separator: "\n").count == 2)
        #expect(text.hasPrefix("Alpha"))
    }

    @Test("a visibility with no windows is left out of the line")
    func omitsEmptyGroups() {
        let text = InventorySummary.text(for: [application("Notes", windows: [.onScreen])])
        #expect(!text.contains("minimised"))
        #expect(!text.contains("hidden"))
    }
}
