import AppKit
import SwitcherCore
import SystemPorts

@MainActor
public final class MenuBarController {
    private let statusItem: NSStatusItem
    private let log: any LogSink
    private let openSettings: @MainActor () -> Void
    private let grantAccessibility: @MainActor () -> Void
    private let openInputMonitoring: @MainActor () -> Void
    private let copyInventory: @MainActor () -> Void
    private let quit: @MainActor () -> Void
    private var state: PermissionState = .intercepting

    public init(
        log: any LogSink,
        openSettings: @escaping @MainActor () -> Void,
        grantAccessibility: @escaping @MainActor () -> Void,
        openInputMonitoring: @escaping @MainActor () -> Void,
        copyInventory: @escaping @MainActor () -> Void,
        quit: @escaping @MainActor () -> Void
    ) {
        self.log = log
        self.openSettings = openSettings
        self.grantAccessibility = grantAccessibility
        self.openInputMonitoring = openInputMonitoring
        self.copyInventory = copyInventory
        self.quit = quit
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = Self.makeMenu(target: self)
        show(.intercepting)
        log.record(.menuBarItemInstalled)
    }

    /// The icon carries the state, because a menu bar app that quietly does nothing looks
    /// exactly like one that works.
    public func show(_ state: PermissionState) {
        self.state = state
        let image = MenuBarIcon.image(for: state)
        statusItem.button?.image = image
        statusItem.button?.title = image == nil ? MenuBarIcon.fallback : ""
        statusItem.menu.map { menu in Self.showPermission(state, in: menu, target: self) }
    }

    /// The menu is built with the words of one language, so a change of language rebuilds
    /// it rather than editing the titles in place (S19).
    public func relabel() {
        statusItem.menu = Self.makeMenu(target: self)
        show(state)
    }

    var itemTitles: [String] {
        statusItem.menu?.items.map(\.title) ?? []
    }

    private static func showPermission(_ state: PermissionState, in menu: NSMenu, target: MenuBarController) {
        for item in menu.items where item.tag == permissionTag { menu.removeItem(item) }
        guard let detail = PermissionMessage.text(for: state) else { return }
        let explanation = NSMenuItem(title: detail, action: nil, keyEquivalent: "")
        explanation.isEnabled = false
        explanation.tag = permissionTag
        menu.insertItem(explanation, at: 0)
        var next = 1
        if state.offersGrant {
            let grant = item(
                title: Localised.text(.menuGrantAccessibility),
                action: #selector(grantSelected),
                key: "",
                target: target
            )
            grant.tag = permissionTag
            menu.insertItem(grant, at: next)
            next += 1
        }
        if state.offersInputMonitoring {
            let pane = item(
                title: Localised.text(.menuOpenInputMonitoring),
                action: #selector(inputMonitoringSelected),
                key: "",
                target: target
            )
            pane.tag = permissionTag
            menu.insertItem(pane, at: next)
            next += 1
        }
        let separator = NSMenuItem.separator()
        separator.tag = permissionTag
        menu.insertItem(separator, at: next)
    }

    private static let permissionTag = 909

    private static func makeMenu(target: MenuBarController) -> NSMenu {
        let menu = NSMenu()
        menu.addItem(
            item(title: Localised.text(.menuSettings), action: #selector(settingsSelected), key: ",", target: target))
        menu.addItem(
            item(
                title: Localised.text(.menuCopyInventory),
                action: #selector(copyInventorySelected),
                key: "c",
                target: target
            ))
        menu.addItem(.separator())
        menu.addItem(item(title: Localised.text(.menuQuit), action: #selector(quitSelected), key: "q", target: target))
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
    private func grantSelected() {
        grantAccessibility()
    }

    @objc
    private func inputMonitoringSelected() {
        openInputMonitoring()
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
