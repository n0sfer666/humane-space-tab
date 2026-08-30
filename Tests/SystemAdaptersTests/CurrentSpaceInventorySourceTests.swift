import Foundation
import SwitcherCore
import SystemPorts
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Current Space inventory source")
struct CurrentSpaceInventorySourceTests {
    private let own = ProcessIdentifier(rawValue: ProcessInfo.processInfo.processIdentifier)

    private func application(_ pid: ProcessIdentifier, _ name: String) -> RunningApplication {
        RunningApplication(
            pid: pid,
            bundleIdentifier: "test.\(name)",
            name: name,
            bundlePath: "/Applications/\(name).app",
            policy: .regular,
            isHidden: false,
            isActive: false
        )
    }

    private func window(_ id: UInt32, _ owner: ProcessIdentifier, layer: Int = 0) -> WindowInfo {
        WindowInfo(id: WindowIdentifier(rawValue: id), owner: owner, layer: layer, alpha: 1, isOnScreen: true)
    }

    private func source(
        applications: [RunningApplication],
        all: [WindowInfo],
        onScreen: [WindowInfo] = [],
        currentSpace: Set<WindowIdentifier>? = nil
    ) -> CurrentSpaceInventorySource {
        CurrentSpaceInventorySource(
            applications: ApplicationSourceStub(applications: applications),
            windows: WindowSourceStub(all: all, onScreen: onScreen),
            hierarchy: ProcessHierarchyStub(),
            spaces: PreferredSpaceMembership(
                preference: SpaceLayerPreferenceStub(prefersPrivateLayer: false),
                privateLayer: SpaceMembershipStub(layer: .skyLight, answer: nil),
                publicLayer: SpaceMembershipStub(layer: .onScreen, answer: currentSpace),
                log: RecordingLogSink()
            )
        )
    }

    @Test("our own application never appears in the inventory")
    func excludesOwnProcess() {
        let other = ProcessIdentifier(rawValue: 42)
        let inventory = source(
            applications: [application(own, "Switcher"), application(other, "Editor")],
            all: [window(1, own), window(2, other)],
            currentSpace: [WindowIdentifier(rawValue: 1), WindowIdentifier(rawValue: 2)]
        )
        .inventory()
        #expect(inventory.applications.map(\.pid) == [other])
    }

    @Test("only the applications of the current Space survive")
    func keepsCurrentSpaceOnly() {
        let here = ProcessIdentifier(rawValue: 10)
        let elsewhere = ProcessIdentifier(rawValue: 11)
        let inventory = source(
            applications: [application(here, "Here"), application(elsewhere, "Elsewhere")],
            all: [window(1, here), window(2, elsewhere)],
            currentSpace: [WindowIdentifier(rawValue: 1)]
        )
        .inventory()
        #expect(inventory.applications.map(\.pid) == [here])
        #expect(inventory.layer == .onScreen)
    }

    @Test("the front to back seed names every owner once, front first")
    func seedsOwnersFrontFirst() {
        let front = ProcessIdentifier(rawValue: 10)
        let back = ProcessIdentifier(rawValue: 11)
        let seed = source(
            applications: [application(front, "Front"), application(back, "Back")],
            all: [],
            onScreen: [window(1, front), window(2, back), window(3, front)]
        )
        .frontToBackApplications()
        #expect(seed == [front, back])
    }

    @Test("a window that is not a real window carries no order")
    func seedIgnoresDecoration() {
        let owner = ProcessIdentifier(rawValue: 10)
        let other = ProcessIdentifier(rawValue: 11)
        let seed = source(
            applications: [application(owner, "Owner"), application(other, "Other")],
            all: [],
            onScreen: [window(1, owner, layer: 25), window(2, other)]
        )
        .frontToBackApplications()
        #expect(seed == [other])
    }
}
