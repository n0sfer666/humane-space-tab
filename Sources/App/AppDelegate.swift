import AppKit
import Foundation
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
    private let surface: OverlayWindowSurface
    private let overlay: OverlayController
    private let preferences: PreferencesCenter
    private let loginItem: LoginItem
    private let inputMonitoring: any InputMonitoringSettings
    private var settings: PreferencesWindowController?
    private var menuBar: MenuBarController?
    private var hotkeys: (any HotkeyEngine)?
    private var permissions: PermissionCenter?
    private var appliedShortcut = Shortcut.commandTab

    init(log: any LogSink) {
        self.log = log
        let store = UserDefaultsPreferencesStore()
        preferences = PreferencesCenter(initial: store.load()) { preferences in
            store.save(preferences)
            log.record(.preferencesChanged)
        }
        loginItem = LoginItem(service: SMAppServiceLoginItem(), log: log)
        inputMonitoring = SystemSettingsInputMonitoring()
        let inventory = InventoryAssembly.make(log: log)
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
        let surface = OverlayWindowSurface(icons: icons)
        self.surface = surface
        overlay = OverlayController(
            surface: surface,
            scheduler: MainQueueOverlayScheduler(),
            watchdog: MainQueueOverlayScheduler()
        )
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        log.record(.applicationDidLaunch)
        preferences.observe { [overlay, surface] preferences in
            overlay.delay = preferences.revealDelay
            surface.screen = preferences.overlayScreen
        }
        activations.observe { [switcher] process in switcher.recordActivation(of: process) }
        let hotkeys = makeHotkeys()
        self.hotkeys = hotkeys
        appliedShortcut = preferences.current.shortcut
        preferences.observe { [weak self] preferences in self?.apply(preferences.shortcut) }
        let permissions = PermissionCenter(
            authority: AXAccessibilityAuthority(),
            engine: hotkeys,
            delivery: CGEventTapKeyDelivery(),
            log: log
        ) { work in
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.trustPollInterval) {
                MainActor.assumeIsolated(work)
            }
        }
        self.permissions = permissions
        menuBar = MenuBarController(
            log: log,
            openSettings: { [weak self] in self?.openSettings() },
            grantAccessibility: { [permissions] in permissions.requestGrant() },
            openInputMonitoring: { [inputMonitoring] in inputMonitoring.open() },
            copyInventory: { [report] in report.copyToDestination() },
            quit: { NSApplication.shared.terminate(nil) }
        )
        permissions.observe { [weak self] state in self?.menuBar?.show(state) }
        permissions.start()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        permissions?.refresh()
    }

    private static let trustPollInterval: TimeInterval = 2

    private func makeHotkeys() -> InterceptingHotkeyEngine {
        InterceptingHotkeyEngine(log: log) { [log, switcher, overlay, icons, preferences] mode in
            CGEventTapHotkeySource(
                shortcut: preferences.current.shortcut,
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
    }

    /// Rebuilding goes through the permission centre because it owns the tap's lifecycle:
    /// while a shortcut is being recorded the tap is stood down, and the one that comes back
    /// afterwards is already built from the shortcut stored here.
    private func apply(_ shortcut: Shortcut) {
        guard shortcut != appliedShortcut else { return }
        appliedShortcut = shortcut
        permissions?.rebuildTap()
    }

    private func openSettings() {
        let settings = settings ?? makeSettings()
        self.settings = settings
        settings.show()
    }

    private func makeSettings() -> PreferencesWindowController {
        PreferencesWindowController(
            center: preferences,
            loginItem: loginItem,
            naming: KeyboardLayoutNaming(),
            recording: recording(),
            requestGrant: { [permissions] in permissions?.requestGrant() }
        )
    }

    private func recording() -> any ShortcutRecorderSource {
        let recorder = CGEventTapShortcutRecorder()
        guard let permissions else { return recorder }
        return SuspendingShortcutRecorder(recorder: recorder, suspension: permissions)
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
