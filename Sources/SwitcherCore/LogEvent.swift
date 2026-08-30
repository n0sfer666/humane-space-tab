public enum LogEvent: CaseIterable, Sendable {
    case applicationDidLaunch
    case applicationWillTerminate
    case menuBarItemInstalled
    case quitRequestedFromMenu
    case inventoryCopiedToPasteboard
    case privateSpaceLayerUnavailable

    public var category: LogCategory {
        switch self {
        case .applicationDidLaunch, .applicationWillTerminate, .privateSpaceLayerUnavailable:
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
        case .privateSpaceLayerUnavailable: "private space layer unavailable, falling back to the public one"
        }
    }
}
