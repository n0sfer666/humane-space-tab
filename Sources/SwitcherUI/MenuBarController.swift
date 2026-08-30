import AppKit
import SwitcherCore
import SystemPorts

@MainActor
public final class MenuBarController {
    private let statusItem: NSStatusItem
    private let log: any LogSink
    private let quit: @MainActor () -> Void

    public init(log: any LogSink, quit: @escaping @MainActor () -> Void) {
        self.log = log
        self.quit = quit
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(
            systemSymbolName: "square.on.square",
            accessibilityDescription: "Humane Space Tab"
        )
        statusItem.menu = Self.makeMenu(target: self)
        log.record(.menuBarItemInstalled)
    }

    private static func makeMenu(target: MenuBarController) -> NSMenu {
        let menu = NSMenu()
        let item = NSMenuItem(title: "Quit Humane Space Tab", action: #selector(quitSelected), keyEquivalent: "q")
        item.target = target
        menu.addItem(item)
        return menu
    }

    @objc
    private func quitSelected() {
        log.record(.quitRequestedFromMenu)
        quit()
    }
}
