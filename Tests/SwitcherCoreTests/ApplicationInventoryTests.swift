import Testing

@testable import SwitcherCore

@Suite("Application inventory")
struct ApplicationInventoryTests {
    private let own = ProcessIdentifier(rawValue: 1)

    private func application(
        _ pid: Int32,
        name: String,
        policy: ActivationPolicy = .regular,
        isHidden: Bool = false,
        isActive: Bool = false
    ) -> RunningApplication {
        RunningApplication(
            pid: ProcessIdentifier(rawValue: pid),
            bundleIdentifier: "test.\(pid)",
            name: name,
            policy: policy,
            isHidden: isHidden,
            isActive: isActive
        )
    }

    private func window(
        _ id: UInt32,
        owner: Int32,
        layer: Int = 0,
        alpha: Double = 1,
        isOnScreen: Bool = true
    ) -> WindowInfo {
        WindowInfo(
            id: WindowIdentifier(rawValue: id),
            owner: ProcessIdentifier(rawValue: owner),
            layer: layer,
            alpha: alpha,
            isOnScreen: isOnScreen
        )
    }

    private func build(_ applications: [RunningApplication], _ windows: [WindowInfo]) -> [SwitchableApplication] {
        ApplicationInventory.build(applications: applications, windows: windows, excluding: own)
    }

    @Test("an accessory application is excluded even when it has windows")
    func excludesAccessory() {
        let result = build([application(2, name: "Agent", policy: .accessory)], [window(10, owner: 2)])
        #expect(result.isEmpty)
    }

    @Test("a prohibited application is excluded")
    func excludesProhibited() {
        #expect(build([application(2, name: "Daemon", policy: .prohibited)], []).isEmpty)
    }

    @Test("a regular application with no windows is included with an empty window list")
    func includesWindowlessRegular() {
        let result = build([application(2, name: "Notes")], [])
        #expect(result.map(\.name) == ["Notes"])
        #expect(result[0].windows.isEmpty)
    }

    @Test("the switcher's own process is excluded")
    func excludesSelf() {
        let result = build([application(1, name: "Humane Space Tab"), application(2, name: "Notes")], [])
        #expect(result.map(\.name) == ["Notes"])
    }

    @Test("a window outside the normal layer is dropped")
    func dropsNonZeroLayer() {
        let result = build([application(2, name: "Notes")], [window(10, owner: 2, layer: 25)])
        #expect(result[0].windows.isEmpty)
    }

    @Test("a fully transparent window is dropped")
    func dropsTransparentWindow() {
        let result = build([application(2, name: "Notes")], [window(10, owner: 2, alpha: 0)])
        #expect(result[0].windows.isEmpty)
    }

    @Test("an off-screen window of a visible application is minimised")
    func offScreenIsMinimised() {
        let result = build([application(2, name: "Notes")], [window(10, owner: 2, isOnScreen: false)])
        #expect(result[0].windows.map(\.visibility) == [.minimised])
    }

    @Test("an off-screen window of a hidden application belongs to the hidden application")
    func offScreenOfHiddenApplication() {
        let result = build(
            [application(2, name: "Notes", isHidden: true)],
            [window(10, owner: 2, isOnScreen: false)]
        )
        #expect(result[0].windows.map(\.visibility) == [.hiddenApplication])
    }

    @Test("an on-screen window of a hidden application stays on screen")
    func onScreenOfHiddenApplication() {
        let result = build([application(2, name: "Notes", isHidden: true)], [window(10, owner: 2)])
        #expect(result[0].windows.map(\.visibility) == [.onScreen])
    }

    @Test("a window owned by an unknown process creates no phantom application")
    func dropsOrphanWindows() {
        let result = build([application(2, name: "Notes")], [window(10, owner: 99)])
        #expect(result.map(\.name) == ["Notes"])
        #expect(result[0].windows.isEmpty)
    }

    @Test("applications sharing a name are ordered by process identifier")
    func ordersByProcessIdentifierOnTie() {
        let result = build([application(9, name: "Safari"), application(3, name: "Safari")], [])
        #expect(result.map(\.pid.rawValue) == [3, 9])
    }

    @Test("names are ordered case-insensitively")
    func ordersCaseInsensitively() {
        let result = build(
            [application(2, name: "zulu"), application(3, name: "Alpha"), application(4, name: "beta")],
            []
        )
        #expect(result.map(\.name) == ["Alpha", "beta", "zulu"])
    }

    @Test("an application whose every window was dropped is still switchable")
    func survivesLosingEveryWindow() {
        let result = build([application(2, name: "Notes")], [window(10, owner: 2, layer: 3)])
        #expect(result.map(\.name) == ["Notes"])
    }

    @Test("windows keep the order the source gave them")
    func preservesWindowOrder() {
        let windows = [window(30, owner: 2), window(10, owner: 2), window(20, owner: 2)]
        let result = build([application(2, name: "Notes")], windows)
        #expect(result[0].windows.map(\.id.rawValue) == [30, 10, 20])
    }

    @Test("the active application is carried through")
    func carriesActiveFlag() {
        let result = build([application(2, name: "Notes", isActive: true)], [])
        #expect(result[0].isActive)
    }
}
