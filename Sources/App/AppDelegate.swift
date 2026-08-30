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
    private let icons: any ApplicationIconSource
    private let overlay: OverlayController
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
        let seed = inventory.frontToBackApplications()
        switcher = SwitcherCoordinator(
            order: MRUOrder(seed: seed),
            snapshot: { inventory.inventory().applications },
            activate: { [activator] process in activator.activate(process) }
        )
        let icons = WorkspaceApplicationIconSource()
        self.icons = icons
        icons.prewarm(seed)
        overlay = OverlayController(
            surface: OverlayWindowSurface(icons: icons),
            scheduler: MainQueueOverlayScheduler(),
            watchdog: MainQueueOverlayScheduler()
        )
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        log.record(.applicationDidLaunch)
        activations.observe { [switcher] process in switcher.recordActivation(of: process) }
        let hotkeys = InterceptingHotkeyEngine(log: log) { [log, switcher, overlay, icons] mode in
            CGEventTapHotkeySource(
                mode: mode,
                log: log,
                sessionOpen: { switcher.isSessionOpen },
                emit: { command in
                    let effect = switcher.handle(command)
                    log.record(LogEvent(effect: effect))
                    let session = switcher.session
                    if effect == .opened, let session {
                        Self.prewarm(session.applications, with: icons)
                    }
                    overlay.render(session.map(OverlayModel.init(session:)))
                }
            )
        }
        self.hotkeys = hotkeys
        hotkeyStatus = hotkeys.start()
        menuBar = MenuBarController(
            log: log,
            copyInventory: { [report] in report.copyToDestination() },
            quit: { NSApplication.shared.terminate(nil) }
        )
    }

    /// An application launched after this one pays its first icon load here, in the gap
    /// between the gesture opening and the ribbon appearing, never inside the tap callback.
    private static func prewarm(
        _ applications: [SwitchableApplication],
        with icons: any ApplicationIconSource
    ) {
        let processes = applications.map(\.pid)
        Task { @MainActor in icons.prewarm(processes) }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeys?.stop()
        activations.stop()
        overlay.render(nil)
        log.record(.applicationWillTerminate)
    }
}
