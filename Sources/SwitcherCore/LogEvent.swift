public enum LogEvent: CaseIterable, Hashable, Sendable {
    case applicationDidLaunch
    case applicationWillTerminate
    case menuBarItemInstalled
    case quitRequestedFromMenu
    case inventoryCopiedToPasteboard
    case privateSpaceLayerUnavailable
    case hotkeyTapStarted
    case hotkeyTapStopped
    case hotkeyTapUnavailable
    case hotkeyTapReenabled
    case hotkeyActivateForward
    case hotkeyActivateBackward
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

    public init(command: HotkeyCommand) {
        switch command {
        case .activate(.forward): self = .hotkeyActivateForward
        case .activate(.backward): self = .hotkeyActivateBackward
        case .step(.forward): self = .hotkeyStepForward
        case .step(.backward): self = .hotkeyStepBackward
        case .cancel: self = .hotkeyCancelled
        case .commit: self = .hotkeyCommitted
        }
    }

    public var category: LogCategory {
        switch self {
        case .applicationDidLaunch, .applicationWillTerminate, .privateSpaceLayerUnavailable:
            .lifecycle
        case .menuBarItemInstalled, .quitRequestedFromMenu, .inventoryCopiedToPasteboard:
            .ui
        case .hotkeyTapStarted, .hotkeyTapStopped, .hotkeyTapUnavailable, .hotkeyTapReenabled,
            .hotkeyActivateForward, .hotkeyActivateBackward, .hotkeyStepForward, .hotkeyStepBackward,
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
        case .inventoryCopiedToPasteboard: "inventory summary copied to the pasteboard"
        case .privateSpaceLayerUnavailable: "private space layer unavailable, falling back to the public one"
        case .hotkeyTapStarted: "hotkey tap started"
        case .hotkeyTapStopped: "hotkey tap stopped"
        case .hotkeyTapUnavailable: "hotkey tap unavailable, accessibility is not granted"
        case .hotkeyTapReenabled: "hotkey tap re-enabled after the system disabled it"
        case .hotkeyActivateForward: "hotkey activated the switcher moving forward"
        case .hotkeyActivateBackward: "hotkey activated the switcher moving backward"
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
