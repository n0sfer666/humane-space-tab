import Testing

@testable import SwitcherCore

@Suite("Window expansion")
struct WindowExpansionTests {
    private func window(_ raw: UInt32, _ visibility: WindowVisibility = .onScreen) -> ApplicationWindow {
        ApplicationWindow(id: WindowIdentifier(rawValue: raw), visibility: visibility)
    }

    private func application(_ raw: Int32, _ windows: [ApplicationWindow]) -> SwitchableApplication {
        SwitchableApplication(
            pid: ProcessIdentifier(rawValue: raw),
            bundleIdentifier: "test.\(raw)",
            name: "App \(raw)",
            isActive: false,
            windows: windows
        )
    }

    private func expand(
        _ applications: [SwitchableApplication],
        onCurrentSpace: [UInt32],
        frontToBack: [UInt32]
    ) -> [SwitcherEntry] {
        WindowExpansion.entries(
            applications: applications,
            onCurrentSpace: Set(onCurrentSpace.map(WindowIdentifier.init(rawValue:))),
            frontToBack: frontToBack.map(WindowIdentifier.init(rawValue:))
        )
    }

    @Test("an application with three windows becomes three entries")
    func expandsWindows() {
        let entries = expand(
            [application(1, [window(10), window(11), window(12)])],
            onCurrentSpace: [10, 11, 12],
            frontToBack: [11, 12, 10]
        )
        #expect(entries.count == 3)
        #expect(entries.allSatisfy { $0.application.pid == ProcessIdentifier(rawValue: 1) })
    }

    @Test("the ribbon order is the stacking order, across applications")
    func ordersByStacking() {
        let entries = expand(
            [application(1, [window(10), window(12)]), application(2, [window(11)])],
            onCurrentSpace: [10, 11, 12],
            frontToBack: [11, 10, 12]
        )
        #expect(entries.map(\.window?.id.rawValue) == [11, 10, 12])
    }

    @Test("an application with no window of this Space stays as one application entry")
    func keepsApplicationWithoutWindows() {
        let entries = expand(
            [application(1, [window(10)]), application(2, [])],
            onCurrentSpace: [10],
            frontToBack: [10]
        )
        #expect(entries.map(\.window?.id.rawValue) == [10, nil])
        #expect(entries.last?.application.pid == ProcessIdentifier(rawValue: 2))
    }

    @Test("a window of another Space is not listed")
    func dropsWindowsOfOtherSpaces() {
        let entries = expand(
            [application(1, [window(10), window(11)])],
            onCurrentSpace: [10],
            frontToBack: [10]
        )
        #expect(entries.map(\.window?.id.rawValue) == [10])
    }

    @Test("a minimised window is listed after the windows on screen")
    func appendsMinimisedWindows() {
        let entries = expand(
            [application(1, [window(10, .minimised), window(11)])],
            onCurrentSpace: [11],
            frontToBack: [11]
        )
        #expect(entries.map(\.window?.id.rawValue) == [11, 10])
    }

    @Test("a hidden application's windows are listed, after the stack")
    func appendsHiddenWindows() {
        let entries = expand(
            [application(1, [window(10)]), application(2, [window(20, .hiddenApplication)])],
            onCurrentSpace: [10],
            frontToBack: [10]
        )
        #expect(entries.map(\.window?.id.rawValue) == [10, 20])
    }

    @Test("windows the stack does not name keep the application order")
    func appendsInApplicationOrder() {
        let entries = expand(
            [
                application(1, [window(10, .minimised)]),
                application(2, [window(20, .minimised)]),
            ],
            onCurrentSpace: [],
            frontToBack: []
        )
        #expect(entries.map(\.window?.id.rawValue) == [10, 20])
    }

    @Test("an empty application list expands to nothing")
    func expandsEmptyList() {
        #expect(expand([], onCurrentSpace: [], frontToBack: []).isEmpty)
    }

    @Test("an entry's target names its application and its window")
    func carriesTargets() {
        let entries = expand(
            [application(1, [window(10)]), application(2, [])],
            onCurrentSpace: [10],
            frontToBack: [10]
        )
        #expect(
            entries.first?.target
                == SwitcherTarget(
                    pid: ProcessIdentifier(rawValue: 1),
                    window: WindowIdentifier(rawValue: 10)
                )
        )
        #expect(entries.last?.target == SwitcherTarget(pid: ProcessIdentifier(rawValue: 2)))
    }
}
