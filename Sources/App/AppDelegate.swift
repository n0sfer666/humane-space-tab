import AppKit
import SwitcherCore
import SwitcherUI
import SystemAdapters
import SystemPorts

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let log: any LogSink
    private let report: InventoryReport
    private var menuBar: MenuBarController?

    init(log: any LogSink) {
        self.log = log
        report = InventoryReport(
            applications: WorkspaceApplicationSource(),
            windows: CoreGraphicsWindowSource(),
            hierarchy: LibprocProcessHierarchy(),
            spaces: PreferredSpaceMembership(
                preference: UserDefaultsSpaceLayerPreference(),
                privateLayer: SkyLightSpaceMembershipSource(),
                publicLayer: OnScreenSpaceMembershipSource(),
                log: log
            ),
            destination: PasteboardTextSink()
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        log.record(.applicationDidLaunch)
        menuBar = MenuBarController(
            log: log,
            copyInventory: { [report] in report.copyToDestination() },
            quit: { NSApplication.shared.terminate(nil) }
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        log.record(.applicationWillTerminate)
    }
}
