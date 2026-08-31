import SwitcherCore
import Testing

@testable import SwitcherUI

@Suite("Overlay model")
struct OverlayModelTests {
    private let application = SwitchableApplication(
        pid: ProcessIdentifier(rawValue: 1),
        bundleIdentifier: nil,
        name: "Notes",
        isActive: false,
        windows: []
    )

    private var windowEntry: SwitcherEntry {
        SwitcherEntry(
            application: application,
            window: ApplicationWindow(id: WindowIdentifier(rawValue: 10), visibility: .onScreen)
        )
    }

    @Test("an entry with a title is labelled with it")
    func labelsWithTheTitle() {
        let entry = windowEntry
        let model = OverlayModel(entries: [entry], selection: 0, titles: [entry.target: "Shopping list"])
        #expect(model.label(of: entry) == "Shopping list")
    }

    @Test("an entry whose title has not arrived keeps its application's name")
    func labelsWithTheApplication() {
        let entry = windowEntry
        #expect(OverlayModel(entries: [entry], selection: 0).label(of: entry) == "Notes")
    }

    @Test("a title belonging to another window does not label this one")
    func ignoresAnotherWindowsTitle() {
        let entry = windowEntry
        let other = SwitcherTarget(pid: application.pid, window: WindowIdentifier(rawValue: 11))
        let model = OverlayModel(entries: [entry], selection: 0, titles: [other: "Shopping list"])
        #expect(model.label(of: entry) == "Notes")
    }
}
