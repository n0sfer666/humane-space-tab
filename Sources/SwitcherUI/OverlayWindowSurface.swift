import AppKit
import SwitcherCore
import SystemPorts

@MainActor
public final class OverlayWindowSurface: OverlaySurface {
    /// Preferences (S08) change this between sessions; the screen is resolved when the
    /// ribbon is placed, not tracked while it is up.
    public var screen: OverlayScreenChoice = .focused

    /// What the pointer did to the ribbon, on its way to the session (S14).
    public var onGesture: ((RibbonGesture) -> Void)? {
        get { content.onGesture }
        set { content.onGesture = newValue }
    }

    private let metrics: OverlayMetrics
    private let panel: NSPanel
    private let content: OverlayContentView
    private var placement: Placement?
    private var scroll = RibbonScroll()

    public init(icons: any ApplicationIconSource, metrics: OverlayMetrics = OverlayMetrics()) {
        self.metrics = metrics
        content = OverlayContentView(icons: icons, metrics: metrics)
        panel = Self.makePanel()
        panel.contentView = OverlayBackdrop.make(cornerRadius: metrics.cornerRadius, content: content)
    }

    public func show(_ model: OverlayModel) {
        scroll.reset()
        content.beginSession()
        guard place(model) else { return }
        panel.orderFrontRegardless()
    }

    public func update(_ model: OverlayModel) {
        _ = place(model)
    }

    public func hide() {
        panel.orderOut(nil)
        placement = nil
    }

    private func place(_ model: OverlayModel) -> Bool {
        guard let area = area() else { return false }
        let layout = layout(for: model.entries.count, in: area)
        let frame = CGRect(
            x: area.midX - layout.size.width / 2,
            y: area.midY - layout.size.height / 2,
            width: layout.size.width,
            height: layout.size.height
        )
        if panel.frame != frame { panel.setFrame(frame, display: false) }
        content.frame = CGRect(origin: .zero, size: layout.size)
        let offset = scroll.settle(
            selection: model.selection,
            count: model.entries.count,
            visible: layout.visible
        )
        content.render(model, layout: layout, offset: offset)
        return true
    }

    private func area() -> CGRect? {
        let screens = NSScreen.screens
        let index = OverlayScreenPicker.index(
            for: screen,
            pointer: NSEvent.mouseLocation,
            frames: screens.map(\.frame),
            focused: NSScreen.main.flatMap { screens.firstIndex(of: $0) }
        )
        guard let index, screens.indices.contains(index) else { return nil }
        return screens[index].visibleFrame
    }

    /// Only the selection changes between the steps of a session, so the geometry is
    /// computed once and reused while the tap callback is on the critical path.
    private func layout(for count: Int, in area: CGRect) -> OverlayLayout {
        if let placement, placement.matches(count: count, area: area.size) { return placement.layout }
        let layout = OverlayLayout.compute(count: count, screen: area.size, metrics: metrics)
        placement = Placement(count: count, area: area.size, layout: layout)
        return layout
    }

    private static func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .popUpMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.ignoresMouseEvents = false
        panel.acceptsMouseMovedEvents = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        return panel
    }
}

private struct Placement {
    let count: Int
    let area: CGSize
    let layout: OverlayLayout

    func matches(count: Int, area: CGSize) -> Bool {
        self.count == count && self.area == area
    }
}
