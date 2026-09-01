import AppKit
import SwitcherCore
import SystemPorts

@MainActor
final class OverlayContentView: NSView {
    private let icons: any ApplicationIconSource
    private var metrics: OverlayMetrics
    private var model = OverlayModel(entries: [], selection: 0)
    private var layout = OverlayLayout.empty
    private var shown: [Int] = []
    private var mouse = RibbonMouse()

    var onGesture: ((RibbonGesture) -> Void)?

    init(icons: any ApplicationIconSource, metrics: OverlayMetrics) {
        self.icons = icons
        self.metrics = metrics
        super.init(frame: .zero)
        wantsLayer = true
        layer?.masksToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override var isFlipped: Bool { true }

    func apply(_ metrics: OverlayMetrics) {
        guard metrics != self.metrics else { return }
        self.metrics = metrics
        needsDisplay = true
    }

    func render(_ model: OverlayModel, layout: OverlayLayout) {
        let shown = CarouselWindow.indices(
            count: model.entries.count,
            selection: model.selection,
            carousel: metrics.carousel
        )
        let travelled =
            self.layout == layout && self.model.entries == model.entries
            ? CarouselShift.between(self.shown, shown) : 0
        self.model = model
        self.layout = layout
        self.shown = shown
        mouse.rendered(layout: layout, window: shown, selection: model.selection)
        needsDisplay = true
        CarouselSlide.apply(shift: travelled, step: layout.step, to: layer)
    }

    func beginSession() {
        shown = []
        mouse.reset()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas { removeTrackingArea(area) }
        addTrackingArea(
            NSTrackingArea(rect: .zero, options: [.mouseMoved, .activeAlways, .inVisibleRect], owner: self)
        )
    }

    override func mouseMoved(with event: NSEvent) {
        hover(event)
    }

    override func mouseDragged(with event: NSEvent) {
        hover(event)
    }

    override func mouseDown(with event: NSEvent) {
        mouse.press(at: point(of: event))
    }

    override func mouseUp(with event: NSEvent) {
        guard let gesture = mouse.release(at: point(of: event)) else { return }
        onGesture?(gesture)
    }

    /// The inertial tail of a flick would keep stepping after the fingers left the glass, and a
    /// switcher that goes on moving by itself switches to the wrong thing.
    override func scrollWheel(with event: NSEvent) {
        guard event.momentumPhase.isEmpty else { return }
        let deltas = ScrollDeltas.of(event)
        guard let scroll = mouse.scrolled(across: deltas.across, down: deltas.down) else { return }
        for _ in 0..<scroll.count { onGesture?(.step(scroll.direction)) }
    }

    private func hover(_ event: NSEvent) {
        guard let gesture = mouse.moved(to: point(of: event)) else { return }
        onGesture?(gesture)
    }

    private func point(of event: NSEvent) -> CGPoint {
        convert(event.locationInWindow, from: nil)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard !model.entries.isEmpty else { return OverlayPlaceholder.draw(metrics, in: bounds) }
        let place = CarouselWindow.place(
            of: model.selection,
            count: model.entries.count,
            carousel: metrics.carousel
        )
        for (slot, entry) in shown.enumerated() where layout.slots.indices.contains(slot) {
            draw(model.entries[entry], in: layout.slots[slot], selected: slot == place)
        }
    }

    /// The selection is the icon at full strength and full size; its neighbours are the same
    /// icons, dimmed and smaller, so the eye lands on the choice without a frame drawn around
    /// it.
    private func draw(_ entry: SwitcherEntry, in slot: CGRect, selected: Bool) {
        let icon = CGRect(x: slot.minX, y: slot.minY, width: layout.iconSide, height: layout.iconSide)
        let drawn = metrics.drawn(icon: icon, selected: selected)
        OverlaySelectionHighlight.draw(behind: drawn, metrics: metrics, selected: selected)
        OverlayIconFrame.draw(
            around: drawn,
            style: metrics.frame,
            icon: layout.iconSide,
            selected: selected,
            metrics: metrics
        )
        icons.icon(for: entry.application.pid)?
            .draw(
                in: drawn,
                from: .zero,
                operation: .sourceOver,
                fraction: selected ? 1 : metrics.dimmed,
                respectFlipped: true,
                hints: nil
            )
        guard selected else { return }
        let name = OverlayName.text(
            model.label(of: entry),
            size: metrics.labelSize(icon: layout.iconSide)
        )
        let area = metrics.nameArea(
            under: slot,
            icon: layout.iconSide,
            text: name.size().width,
            panel: bounds.width
        )
        OverlayName.draw(name, in: area)
    }
}
