import AppKit
import SwitcherCore
import SystemPorts

@MainActor
public final class PreferencesWindowController {
    private let window: NSWindow

    /// The form is the only writer of these preferences, so it does not observe the
    /// centre: a value echoed back mid-drag would fight the slider.
    public init(
        center: PreferencesCenter,
        appearance: AppearanceCenter,
        loginItem: LoginItem,
        naming: any KeyNaming,
        recording: any ShortcutRecorderSource,
        requestGrant: @escaping @MainActor () -> Void
    ) {
        let form = PreferencesFormView(
            preferences: center.current,
            loginItem: loginItem,
            formatter: ShortcutFormatter(naming: naming),
            recording: recording,
            requestGrant: requestGrant
        ) { [center] in
            center.update($0)
        }
        let tabs = SettingsTabsController(
            general: form,
            appearance: AppearanceTabView(center: appearance)
        )
        window = NSWindow(contentViewController: tabs)
        window.styleMask = [.titled, .closable]
        window.title = Localised.text(.settingsTitle)
        window.isReleasedWhenClosed = false
        window.center()
    }

    /// The app is an accessory, so it has to ask for activation before its only ordinary
    /// window can take the keyboard.
    public func show() {
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    /// A window built in one language cannot be relabelled item by item, so a change of
    /// language throws it away and the next one is built afresh (S19).
    public func close() {
        window.close()
    }

    public var isOpen: Bool { window.isVisible }
}
