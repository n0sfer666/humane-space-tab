import Foundation
import SwitcherCore
import SystemAdapters
import SystemPorts

@MainActor
struct InventoryReport {
    private let applications: any ApplicationSource
    private let windows: any WindowSource
    private let hierarchy: any ProcessHierarchy
    private let spaces: PreferredSpaceMembership
    private let destination: any TextSink

    init(
        applications: any ApplicationSource,
        windows: any WindowSource,
        hierarchy: any ProcessHierarchy,
        spaces: PreferredSpaceMembership,
        destination: any TextSink
    ) {
        self.applications = applications
        self.windows = windows
        self.hierarchy = hierarchy
        self.spaces = spaces
        self.destination = destination
    }

    func copyToDestination() {
        let running = applications.runningApplications()
        let owned = WindowOwnership.resolve(
            windows: windows.windows().filter(\.isReal),
            regularApplications: ApplicationInventory.regularBundlePaths(in: running),
            executablePath: hierarchy.executablePath,
            parent: hierarchy.parent
        )
        let inventory = ApplicationInventory.build(
            applications: running,
            windows: owned,
            excluding: ProcessIdentifier(rawValue: ProcessInfo.processInfo.processIdentifier)
        )
        let membership = spaces.membership(among: owned)
        let current = CurrentSpaceFilter.apply(to: inventory, windowsOnCurrentSpace: membership.windows)
        destination.write(InventorySummary.text(for: current, layer: membership.layer))
    }
}
