import AppKit
import SwitcherCore
import SwitcherUI
import SystemAdapters
import SystemPorts

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let log: any LogSink
    private let report: InventoryReport
    private let activations: any ApplicationActivationObserver
    private let activator: any ApplicationActivator
    private let switcher: SwitcherCoordinator
    private var menuBar: MenuBarController?
    private var hotkeys: (any HotkeyEngine)?
    private var hotkeyStatus: HotkeyEngineStatus = .unavailable

    init(log: any LogSink) {
        self.log = log
        let inventory = CurrentSpaceInventorySource(
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
        report = InventoryReport(inventory: inventory, destination: PasteboardTextSink())
        activations = WorkspaceActivationObserver()
        let activator = WorkspaceApplicationActivator()
        self.activator = activator
        switcher = SwitcherCoordinator(
            order: MRUOrder(seed: inventory.frontToBackApplications()),
            snapshot: { inventory.inventory().applications },
            activate: { [activator] process in activator.activate(process) }
        )
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        log.record(.applicationDidLaunch)
        activations.observe { [switcher] process in switcher.recordActivation(of: process) }
        let hotkeys = CGEventTapHotkeySource(
            mode: .observe,
            log: log,
            sessionOpen: { [switcher] in switcher.isSessionOpen },
            emit: { [log, switcher] command in log.record(LogEvent(effect: switcher.handle(command))) }
        )
        self.hotkeys = hotkeys
        hotkeyStatus = hotkeys.start()
        menuBar = MenuBarController(
            log: log,
            copyInventory: { [report] in report.copyToDestination() },
            quit: { NSApplication.shared.terminate(nil) }
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeys?.stop()
        activations.stop()
        log.record(.applicationWillTerminate)
    }
}
