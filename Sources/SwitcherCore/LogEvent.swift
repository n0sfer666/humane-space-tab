public enum LogEvent: CaseIterable, Sendable {
    case applicationDidLaunch
    case applicationWillTerminate
    case menuBarItemInstalled
    case quitRequestedFromMenu
    case inventoryCopiedToPasteboard

    public var category: LogCategory {
        switch self {
        case .applicationDidLaunch, .applicationWillTerminate:
            .lifecycle
        case .menuBarItemInstalled, .quitRequestedFromMenu, .inventoryCopiedToPasteboard:
            .ui
        }
    }

    public var message: String {
        switch self {
        case .applicationDidLaunch: "application did launch"
        case .applicationWillTerminate: "application will terminate"
        case .menuBarItemInstalled: "menu bar item installed"
        case .quitRequestedFromMenu: "quit requested from menu"
        case .inventoryCopiedToPasteboard: "inventory summary copied to the pasteboard"
        }
    }
}
