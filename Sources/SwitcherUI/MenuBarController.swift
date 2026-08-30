import AppKit
import SwitcherCore
import SystemPorts

@MainActor
public final class MenuBarController {
    private let statusItem: NSStatusItem
    private let log: any LogSink
    private let openSettings: @MainActor () -> Void
    private let copyInventory: @MainActor () -> Void
    private let quit: @MainActor () -> Void

    public init(
        log: any LogSink,
        openSettings: @escaping @MainActor () -> Void,
        copyInventory: @escaping @MainActor () -> Void,
        quit: @escaping @MainActor () -> Void
    ) {
        self.log = log
        self.openSettings = openSettings
        self.copyInventory = copyInventory
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
        menu.addItem(item(title: "Settings…", action: #selector(settingsSelected), key: ",", target: target))
        menu.addItem(item(title: "Copy Inventory", action: #selector(copyInventorySelected), key: "c", target: target))
        menu.addItem(.separator())
        menu.addItem(item(title: "Quit Humane Space Tab", action: #selector(quitSelected), key: "q", target: target))
        return menu
    }

    private static func item(
        title: String,
        action: Selector,
        key: String,
        target: MenuBarController
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = target
        return item
    }

    @objc
    private func settingsSelected() {
        log.record(.settingsOpenedFromMenu)
        openSettings()
    }

    @objc
    private func copyInventorySelected() {
        copyInventory()
        log.record(.inventoryCopiedToPasteboard)
    }

    @objc
    private func quitSelected() {
        log.record(.quitRequestedFromMenu)
        quit()
    }
}
