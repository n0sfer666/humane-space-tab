import SwitcherCore
import SystemAdapters
import SystemPorts

/// Where the switcher's adapters are put together: what the ribbon lists (S16), in which
/// order (S05), and what a commit does (S06). The delegate composes the app, not this.
@MainActor
enum SwitcherAssembly {
    static func make(
        inventory: CurrentSpaceInventorySource,
        seed: [ProcessIdentifier],
        log: any LogSink
    ) -> SwitcherCoordinator {
        let activation = TargetActivation(
            activator: WorkspaceApplicationActivator(),
            raiser: AXWindowRaiser()
        )
        let expansion = EntryExpansion(
            inventory: inventory,
            preference: UserDefaultsWindowSwitching(),
            identity: AXWindowIdentity(),
            log: log
        )
        return SwitcherCoordinator(
            order: MRUOrder(seed: seed),
            snapshot: { inventory.inventory() },
            expand: { expansion.entries($0, onCurrentSpace: $1) },
            cycle: { expansion.cycle($0, onCurrentSpace: $1) },
            activate: { activation.activate($0) }
        )
    }
}
