public enum LogEvent: CaseIterable, Hashable, Sendable {
    case applicationDidLaunch
    case applicationWillTerminate
    case menuBarItemInstalled
    case quitRequestedFromMenu
    case settingsOpenedFromMenu
    case preferencesChanged
    case loginItemChangeFailed
    case accessibilityRequested
    case accessibilityBlocked
    case accessibilityDeaf
    case accessibilitySecured
    case accessibilityObservingOnly
    case accessibilityIntercepting
    case inventoryCopiedToPasteboard
    case privateSpaceLayerUnavailable
    case windowListUnavailable
    case windowListUnanswered
    case hotkeyTapStarted
    case hotkeyTapStopped
    case hotkeyTapUnavailable
    case hotkeyTapReenabled
    case hotkeyInterceptUnavailable
    case hotkeyActivateForward
    case hotkeyActivateBackward
    case hotkeyActivateWindowsForward
    case hotkeyActivateWindowsBackward
    case hotkeyStepForward
    case hotkeyStepBackward
    case hotkeyCancelled
    case hotkeyCommitted
    case switcherSessionOpened
    case switcherSelectionMoved
    case switcherSessionCancelled
    case switcherSessionCommitted
    case switcherCommandIgnored
    case switcherActivationFailed

    public init(effect: SwitcherEffect) {
        switch effect {
        case .ignored: self = .switcherCommandIgnored
        case .opened: self = .switcherSessionOpened
        case .moved: self = .switcherSelectionMoved
        case .cancelled: self = .switcherSessionCancelled
        case .committed: self = .switcherSessionCommitted
        case .activationFailed: self = .switcherActivationFailed
        }
    }

    public init(permission: PermissionState) {
        switch permission {
        case .blocked: self = .accessibilityBlocked
        case .deaf: self = .accessibilityDeaf
        case .secured: self = .accessibilitySecured
        case .observing: self = .accessibilityObservingOnly
        case .intercepting: self = .accessibilityIntercepting
        }
    }

    public init(command: HotkeyCommand) {
        switch command {
        case .activate(.forward, .applications): self = .hotkeyActivateForward
        case .activate(.backward, .applications): self = .hotkeyActivateBackward
        case .activate(.forward, .frontWindows): self = .hotkeyActivateWindowsForward
        case .activate(.backward, .frontWindows): self = .hotkeyActivateWindowsBackward
        case .step(.forward): self = .hotkeyStepForward
        case .step(.backward): self = .hotkeyStepBackward
        case .cancel: self = .hotkeyCancelled
        case .commit: self = .hotkeyCommitted
        }
    }

    public var category: LogCategory {
        switch self {
        case .applicationDidLaunch, .applicationWillTerminate, .privateSpaceLayerUnavailable,
            .windowListUnavailable, .windowListUnanswered:
            .lifecycle
        case .menuBarItemInstalled, .quitRequestedFromMenu, .inventoryCopiedToPasteboard,
            .settingsOpenedFromMenu, .preferencesChanged, .loginItemChangeFailed,
            .accessibilityRequested, .accessibilityBlocked, .accessibilityDeaf, .accessibilitySecured,
            .accessibilityObservingOnly,
            .accessibilityIntercepting:
            .ui
        case .hotkeyTapStarted, .hotkeyTapStopped, .hotkeyTapUnavailable, .hotkeyTapReenabled,
            .hotkeyInterceptUnavailable,
            .hotkeyActivateForward, .hotkeyActivateBackward, .hotkeyActivateWindowsForward,
            .hotkeyActivateWindowsBackward, .hotkeyStepForward, .hotkeyStepBackward,
            .hotkeyCancelled, .hotkeyCommitted:
            .hotkey
        case .switcherSessionOpened, .switcherSelectionMoved, .switcherSessionCancelled,
            .switcherSessionCommitted, .switcherCommandIgnored, .switcherActivationFailed:
            .switcher
        }
    }

    public var message: String {
        switch self {
        case .applicationDidLaunch: "application did launch"
        case .applicationWillTerminate: "application will terminate"
        case .menuBarItemInstalled: "menu bar item installed"
        case .quitRequestedFromMenu: "quit requested from menu"
        case .settingsOpenedFromMenu: "settings opened from menu"
        case .preferencesChanged: "preferences changed"
        case .loginItemChangeFailed: "the system refused to change the login item"
        case .accessibilityRequested: "accessibility requested"
        case .accessibilityBlocked: "accessibility is missing, the switcher is idle"
        case .accessibilityDeaf: "the tap receives no key presses, input monitoring is refusing them"
        case .accessibilitySecured: "secure input is held, so the window server hands the tap no key presses"
        case .accessibilityObservingOnly: "the tap can observe but not intercept"
        case .accessibilityIntercepting: "the switcher is intercepting the shortcut"
        case .inventoryCopiedToPasteboard: "inventory summary copied to the pasteboard"
        case .privateSpaceLayerUnavailable: "private space layer unavailable, falling back to the public one"
        case .windowListUnavailable: "this system names no window behind an element, the ribbon lists applications"
        case .windowListUnanswered: "no application named a window, the ribbon lists applications"
        case .hotkeyTapStarted: "hotkey tap started"
        case .hotkeyTapStopped: "hotkey tap stopped"
        case .hotkeyTapUnavailable: "hotkey tap unavailable, accessibility is not granted"
        case .hotkeyTapReenabled: "hotkey tap re-enabled after the system disabled it"
        case .hotkeyInterceptUnavailable: "interception unavailable, falling back to observation"
        case .hotkeyActivateForward: "hotkey activated the switcher moving forward"
        case .hotkeyActivateBackward: "hotkey activated the switcher moving backward"
        case .hotkeyActivateWindowsForward: "hotkey activated the window switcher moving forward"
        case .hotkeyActivateWindowsBackward: "hotkey activated the window switcher moving backward"
        case .hotkeyStepForward: "hotkey stepped forward"
        case .hotkeyStepBackward: "hotkey stepped backward"
        case .hotkeyCancelled: "hotkey cancelled the session"
        case .hotkeyCommitted: "hotkey committed the session"
        case .switcherSessionOpened: "switcher session opened"
        case .switcherSelectionMoved: "switcher selection moved"
        case .switcherSessionCancelled: "switcher session cancelled"
        case .switcherSessionCommitted: "switcher session committed"
        case .switcherCommandIgnored: "switcher ignored a command that does not apply"
        case .switcherActivationFailed: "switcher could not raise the committed application"
        }
    }
}
