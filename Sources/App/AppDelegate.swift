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
    private let runtime: SessionRuntime
    private let surface: OverlayWindowSurface
    private let presenter: SessionPresenter
    private let preferences: PreferencesCenter
    private let appearance: AppearanceCenter
    private let loginItem: LoginItem
    private let inputMonitoring: any InputMonitoringSettings
    private var settings: PreferencesWindowController?
    private var menuBar: MenuBarController?
    private var hotkeys: (any HotkeyEngine)?
    private var permissions: PermissionCenter?
    private var appliedShortcuts = ShortcutSet.standard

    init(log: any LogSink) {
        self.log = log
        let store = UserDefaultsPreferencesStore()
        preferences = PreferencesCenter(initial: store.load()) { preferences in
            store.save(preferences)
            log.record(.preferencesChanged)
        }
        let looks = UserDefaultsAppearanceStore()
        appearance = AppearanceCenter(initial: looks.load()) { book in looks.save(book) }
        loginItem = LoginItem(service: SMAppServiceLoginItem(), log: log)
        inputMonitoring = SystemSettingsInputMonitoring()
        let inventory = InventoryAssembly.make(log: log)
        report = InventoryReport(inventory: inventory, destination: PasteboardTextSink())
        activations = WorkspaceActivationObserver()
        let seed = inventory.frontToBackApplications()
        let switcher = SwitcherAssembly.make(inventory: inventory, seed: seed, log: log)
        let icons = WorkspaceApplicationIconSource()
        icons.prewarm(seed)
        let surface = OverlayWindowSurface(icons: icons)
        self.surface = surface
        let presenter = SessionPresenter(
            overlay: OverlayController(
                surface: surface,
                scheduler: MainQueueOverlayScheduler(),
                watchdog: MainQueueOverlayScheduler()
            ),
            icons: icons,
            titles: SessionTitles(source: AXWindowTitles())
        )
        self.presenter = presenter
        runtime = SessionRuntime(switcher: switcher, presenter: presenter, log: log)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        log.record(.applicationDidLaunch)
        Localised.language = preferences.current.language
        preferences.observe { [weak self] preferences in self?.apply(preferences.language) }
        preferences.observe { [presenter, surface] preferences in
            presenter.delay = preferences.revealDelay
            surface.screen = preferences.overlayScreen
        }
        appearance.observe { [surface] book in surface.appearance = book.active.appearance }
        activations.observe { [runtime] process in runtime.recordActivation(of: process) }
        surface.onGesture = { [runtime] gesture in runtime.handle(gesture) }
        let hotkeys = makeHotkeys()
        self.hotkeys = hotkeys
        appliedShortcuts = preferences.current.shortcuts
        preferences.observe { [weak self] preferences in self?.apply(preferences.shortcuts) }
        let permissions = PermissionCenter(
            authority: AXAccessibilityAuthority(),
            engine: hotkeys,
            delivery: CGEventTapKeyDelivery(),
            secureInput: CGSessionSecureInput(),
            log: log,
            now: { Date.timeIntervalSinceReferenceDate },
            poll: { work in
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.pollInterval) {
                    MainActor.assumeIsolated(work)
                }
            }
        )
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
        permissions.requestGrantIfMissing()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        permissions?.refresh()
    }

    /// A menu bar item is not guaranteed a slot: a bar already full to the notch simply drops
    /// it, and with it every way into the app. Opening the app again is then the way back in.
    func applicationShouldHandleReopen(_ application: NSApplication, hasVisibleWindows: Bool) -> Bool {
        openSettings()
        return true
    }

    private static let pollInterval: TimeInterval = 2

    private func makeHotkeys() -> InterceptingHotkeyEngine {
        InterceptingHotkeyEngine(log: log) { [log, runtime, preferences] mode in
            CGEventTapHotkeySource(
                shortcuts: preferences.current.shortcuts,
                mode: mode,
                log: log,
                session: { runtime.openScope },
                emit: { command in runtime.perform(command) }
            )
        }
    }

    /// Rebuilding goes through the permission centre because it owns the tap's lifecycle:
    /// while a shortcut is being recorded the tap is stood down, and the one that comes back
    /// afterwards is already built from the shortcut stored here.
    /// Nothing built in the old language can be relabelled in place, so the menu and the
    /// settings window are made again — the window reopens where it was, so the choice can
    /// be seen taking effect (S19).
    private func apply(_ language: InterfaceLanguage) {
        guard language != Localised.language else { return }
        Localised.language = language
        menuBar?.relabel()
        guard let open = settings, open.isOpen else { return }
        open.close()
        settings = nil
        openSettings()
    }

    private func apply(_ shortcuts: ShortcutSet) {
        guard shortcuts != appliedShortcuts else { return }
        appliedShortcuts = shortcuts
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
            appearance: appearance,
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

    func applicationWillTerminate(_ notification: Notification) {
        hotkeys?.stop()
        activations.stop()
        runtime.end()
        log.record(.applicationWillTerminate)
    }
}
