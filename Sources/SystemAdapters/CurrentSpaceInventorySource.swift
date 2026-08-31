import Foundation
import SwitcherCore
import SystemPorts

@MainActor
public struct CurrentSpaceInventorySource: SpaceInventorySource {
    private let applications: any ApplicationSource
    private let windows: any WindowSource
    private let hierarchy: any ProcessHierarchy
    private let spaces: PreferredSpaceMembership

    public init(
        applications: any ApplicationSource,
        windows: any WindowSource,
        hierarchy: any ProcessHierarchy,
        spaces: PreferredSpaceMembership
    ) {
        self.applications = applications
        self.windows = windows
        self.hierarchy = hierarchy
        self.spaces = spaces
    }

    public func inventory() -> SpaceInventory {
        let running = applications.runningApplications()
        let owned = own(windows.windows(), by: running)
        let inventory = ApplicationInventory.build(
            applications: running,
            windows: owned,
            excluding: ProcessIdentifier(rawValue: ProcessInfo.processInfo.processIdentifier)
        )
        let membership = spaces.membership(among: owned)
        return SpaceInventory(
            applications: CurrentSpaceFilter.apply(to: inventory, windowsOnCurrentSpace: membership.windows),
            windowsOnCurrentSpace: membership.windows,
            layer: membership.layer
        )
    }

    public func frontToBackApplications() -> [ProcessIdentifier] {
        let owned = own(windows.onScreenWindows(), by: applications.runningApplications())
        var seen: Set<ProcessIdentifier> = []
        return owned.map(\.owner).filter { seen.insert($0).inserted }
    }

    public func frontToBackWindows() -> [WindowIdentifier] {
        windows.onScreenWindows().filter(\.isReal).map(\.id)
    }

    private func own(_ windows: [WindowInfo], by running: [RunningApplication]) -> [WindowInfo] {
        WindowOwnership.resolve(
            windows: windows.filter(\.isReal),
            regularApplications: ApplicationInventory.regularBundlePaths(in: running),
            executablePath: hierarchy.executablePath,
            parent: hierarchy.parent
        )
    }
}
