import AppKit
import SwitcherCore

@MainActor
public final class PreferencesWindowController {
    private let window: NSWindow

    /// The form is the only writer of these preferences, so it does not observe the
    /// centre: a value echoed back mid-drag would fight the slider.
    public init(center: PreferencesCenter) {
        let form = PreferencesFormView(preferences: center.current) { [center] in center.update($0) }
        window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 420, height: 240),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Humane Space Tab Settings"
        window.isReleasedWhenClosed = false
        window.contentView = form
        window.setContentSize(form.fittingSize)
        window.center()
    }

    /// The app is an accessory, so it has to ask for activation before its only ordinary
    /// window can take the keyboard.
    public func show() {
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }
}
