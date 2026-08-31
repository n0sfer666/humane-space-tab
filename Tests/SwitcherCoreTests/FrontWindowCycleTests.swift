import Testing

@testable import SwitcherCore

@Suite("Front window cycle")
struct FrontWindowCycleTests {
    private func window(_ raw: UInt32, _ visibility: WindowVisibility = .onScreen) -> ApplicationWindow {
        ApplicationWindow(id: WindowIdentifier(rawValue: raw), visibility: visibility)
    }

    private func application(_ windows: [ApplicationWindow]) -> SwitchableApplication {
        SwitchableApplication(
            pid: ProcessIdentifier(rawValue: 1),
            bundleIdentifier: "test.1",
            name: "App",
            isActive: true,
            windows: windows
        )
    }

    private func cycle(
        _ front: SwitchableApplication?,
        onCurrentSpace: [UInt32],
        frontToBack: [UInt32]
    ) -> [UInt32] {
        FrontWindowCycle.entries(
            front: front,
            onCurrentSpace: Set(onCurrentSpace.map(WindowIdentifier.init(rawValue:))),
            frontToBack: frontToBack.map(WindowIdentifier.init(rawValue:))
        )
        .compactMap { $0.window?.id.rawValue }
    }

    @Test("the windows of this Space are listed in stacking order")
    func listsThisSpaceInStackingOrder() {
        let entries = cycle(
            application([window(10), window(11), window(12)]),
            onCurrentSpace: [10, 11, 12],
            frontToBack: [11, 12, 10]
        )
        #expect(entries == [11, 12, 10])
    }

    @Test("a window of another Space is not listed")
    func skipsOtherSpaces() {
        #expect(
            cycle(
                application([window(10), window(11)]),
                onCurrentSpace: [10],
                frontToBack: [10, 11]
            ) == [10]
        )
    }

    @Test("a minimised window is not listed")
    func skipsMinimised() {
        #expect(
            cycle(
                application([window(10), window(11, .minimised)]),
                onCurrentSpace: [10],
                frontToBack: [10]
            ) == [10]
        )
    }

    @Test("a window the stacking list does not name is appended in inventory order")
    func appendsUnstacked() {
        #expect(
            cycle(
                application([window(10), window(11), window(12)]),
                onCurrentSpace: [10, 11, 12],
                frontToBack: [12]
            ) == [12, 10, 11]
        )
    }

    @Test("every entry names the front application and its own window")
    func entriesCarryTheApplication() {
        let entries = FrontWindowCycle.entries(
            front: application([window(10), window(11)]),
            onCurrentSpace: [WindowIdentifier(rawValue: 10), WindowIdentifier(rawValue: 11)],
            frontToBack: [WindowIdentifier(rawValue: 10)]
        )
        #expect(entries.allSatisfy { $0.application.pid == ProcessIdentifier(rawValue: 1) })
        #expect(entries.allSatisfy { $0.window != nil })
    }

    @Test("no front application means nothing to cycle")
    func noFrontApplication() {
        #expect(cycle(nil, onCurrentSpace: [10], frontToBack: [10]).isEmpty)
    }
}
