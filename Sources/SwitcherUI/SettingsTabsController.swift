import AppKit

/// The settings window's two halves. General is what the switcher does; Appearance is what
/// it looks like. They are kept apart because they are read at different moments: the first
/// once, when the shortcut is settled, the second whenever the ribbon is not to one's taste.
@MainActor
final class SettingsTabsController: NSTabViewController {
    init(general: NSView, appearance: NSView) {
        super.init(nibName: nil, bundle: nil)
        tabStyle = .toolbar
        add(general, title: "General", symbol: "gearshape")
        add(appearance, title: "Appearance", symbol: "paintpalette")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private func add(_ content: NSView, title: String, symbol: String) {
        let item = NSTabViewItem(viewController: SettingsPane(content: content, title: title))
        item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: title)
        addTabViewItem(item)
    }
}
