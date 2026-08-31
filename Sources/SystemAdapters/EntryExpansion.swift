import SwitcherCore
import SystemPorts

/// Which unit the ribbon lists (S16). With the preference off nothing here asks the system
/// anything, so an app that switches applications makes no accessibility call at all.
@MainActor
public struct EntryExpansion {
    private let inventory: any SpaceInventorySource
    private let preference: any WindowSwitchingPreference

    public init(inventory: any SpaceInventorySource, preference: any WindowSwitchingPreference) {
        self.inventory = inventory
        self.preference = preference
    }

    public func entries(
        _ applications: [SwitchableApplication],
        onCurrentSpace: Set<WindowIdentifier>
    ) -> [SwitcherEntry] {
        guard preference.switchesWindows else {
            return applications.map { SwitcherEntry(application: $0) }
        }
        return WindowExpansion.entries(
            applications: applications,
            onCurrentSpace: onCurrentSpace,
            frontToBack: inventory.frontToBackWindows()
        )
    }
}
