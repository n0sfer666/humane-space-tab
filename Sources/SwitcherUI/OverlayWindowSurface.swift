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

    /// The look the active profile asks for (S17). A change lands on the next session
    /// rather than mid-gesture: the panel is built when the ribbon is shown, and the
    /// geometry it was placed with is thrown away here so it is computed afresh.
    public var appearance: Appearance = .standard {
        didSet {
            guard appearance != oldValue else { return }
            metrics = OverlayMetrics(appearance: appearance)
            content.apply(metrics)
            placement = nil
        }
    }

    private var metrics: OverlayMetrics
    private let content: OverlayContentView
    private(set) var panel: NSPanel
    private var placement: Placement?

    public init(icons: any ApplicationIconSource, metrics: OverlayMetrics = OverlayMetrics()) {
        self.metrics = metrics
        content = OverlayContentView(icons: icons, metrics: metrics)
        panel = Self.makePanel(around: content, appearance: .standard, cornerRadius: metrics.cornerRadius)
    }

    public func show(_ model: OverlayModel) {
        content.beginSession()
        renew()
        guard place(model) else { return }
        panel.orderFrontRegardless()
    }

    /// The window server settles which Spaces a window belongs to when it registers it, and a
    /// panel that has been up for hours can end up belonging to none of the Spaces in use: the
    /// session opens, the gesture works, and there is nothing on screen to see it by. Every
    /// session brings its own window, so membership is decided the moment the ribbon is needed.
    private func renew() {
        let previous = panel
        panel = Self.makePanel(around: content, appearance: appearance, cornerRadius: metrics.cornerRadius)
        previous.orderOut(nil)
        previous.close()
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
        content.render(model, layout: layout)
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

    private static func makePanel(around content: NSView, appearance: Appearance, cornerRadius: CGFloat) -> NSPanel {
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
        panel.contentView = OverlayBackdrop.make(
            cornerRadius: cornerRadius,
            background: appearance.background,
            content: content
        )
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
