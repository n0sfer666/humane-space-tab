import Testing

@testable import SwitcherCore

@Suite("Current space filter")
struct CurrentSpaceFilterTests {
    private func application(_ name: String, pid: Int32, windows: [UInt32]) -> SwitchableApplication {
        SwitchableApplication(
            pid: ProcessIdentifier(rawValue: pid),
            bundleIdentifier: "test.\(pid)",
            name: name,
            isActive: false,
            windows: windows.map { ApplicationWindow(id: WindowIdentifier(rawValue: $0), visibility: .onScreen) }
        )
    }

    private func apply(_ applications: [SwitchableApplication], onCurrentSpace: [UInt32]) -> [String] {
        CurrentSpaceFilter.apply(
            to: applications,
            windowsOnCurrentSpace: Set(onCurrentSpace.map { WindowIdentifier(rawValue: $0) })
        )
        .map(\.name)
    }

    @Test("an application with a window on the current space is kept")
    func keepsApplicationOnCurrentSpace() {
        let result = apply([application("Notes", pid: 2, windows: [10])], onCurrentSpace: [10])
        #expect(result == ["Notes"])
    }

    @Test("an application whose windows all live elsewhere is dropped")
    func dropsApplicationElsewhere() {
        let result = apply([application("Mail", pid: 3, windows: [20, 21])], onCurrentSpace: [10])
        #expect(result.isEmpty)
    }

    @Test("an application with no windows is kept, having nowhere else to be")
    func keepsWindowlessApplication() {
        #expect(apply([application("Notes", pid: 2, windows: [])], onCurrentSpace: [10]) == ["Notes"])
    }

    @Test("one window on the current space is enough")
    func oneWindowIsEnough() {
        let result = apply([application("Arc", pid: 4, windows: [20, 21, 10, 22])], onCurrentSpace: [10])
        #expect(result == ["Arc"])
    }

    @Test("an empty current space leaves only windowless applications")
    func emptyCurrentSpace() {
        let applications = [application("Mail", pid: 3, windows: [20]), application("Notes", pid: 2, windows: [])]
        #expect(apply(applications, onCurrentSpace: []) == ["Notes"])
    }

    @Test("an empty inventory yields an empty result")
    func emptyInventory() {
        #expect(apply([], onCurrentSpace: [10]).isEmpty)
    }

    @Test("the order of the inventory is preserved")
    func preservesOrder() {
        let applications = [
            application("Alpha", pid: 2, windows: [10]),
            application("Beta", pid: 3, windows: [20]),
            application("Gamma", pid: 4, windows: [11]),
        ]
        #expect(apply(applications, onCurrentSpace: [10, 11]) == ["Alpha", "Gamma"])
    }
}
