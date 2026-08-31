import SystemAdapters
import SystemPorts

/// Where the inventory's adapters are put together. The switcher asks one question — which
/// applications are on this Space — and four system sources answer it between them; the
/// delegate composes the app, not the answer.
@MainActor
enum InventoryAssembly {
    static func make(log: any LogSink) -> CurrentSpaceInventorySource {
        CurrentSpaceInventorySource(
            applications: WorkspaceApplicationSource(),
            windows: CoreGraphicsWindowSource(),
            hierarchy: LibprocProcessHierarchy(),
            spaces: PreferredSpaceMembership(
                preference: UserDefaultsSpaceLayerPreference(),
                privateLayer: SkyLightSpaceMembershipSource(),
                publicLayer: OnScreenSpaceMembershipSource(),
                log: log
            )
        )
    }
}
