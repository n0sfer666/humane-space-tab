import AppKit
import SwitcherCore
import SystemPorts

@MainActor
final class OverlayContentView: NSView {
    private let icons: any ApplicationIconSource
    private let metrics: OverlayMetrics
    private var model = OverlayModel(entries: [], selection: 0)
    private var layout = OverlayLayout.empty
    private var offset = 0
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

    func render(_ model: OverlayModel, layout: OverlayLayout, offset: Int) {
        mouse.rendered(layout: layout, offset: offset, selection: model.selection)
        let previous = self.model
        let stepped =
            self.layout == layout && self.offset == offset
            && previous.entries == model.entries && previous.titles == model.titles
        self.model = model
        self.layout = layout
        self.offset = offset
        guard stepped, let changed = changedArea(from: previous.selection, to: model.selection) else {
            needsDisplay = true
            return
        }
        setNeedsDisplay(changed)
    }

    func beginSession() {
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

    /// A step repaints the tile that lost the selection and the one that gained it, not the
    /// ribbon — grown by the room the tile and the name take outside their slot.
    private func changedArea(from previous: Int, to current: Int) -> CGRect? {
        let slots = layout.slots
        guard slots.indices.contains(previous), slots.indices.contains(current) else { return nil }
        let bleed = max(metrics.tilePadding(icon: layout.iconSide), layout.iconSide) + 1
        return place(slots[previous].union(slots[current])).insetBy(dx: -bleed, dy: -bleed)
    }

    private func place(_ slot: CGRect) -> CGRect {
        slot.offsetBy(dx: -CGFloat(offset) * layout.step, dy: 0)
    }

    override func draw(_ dirtyRect: NSRect) {
        for (index, slot) in layout.slots.enumerated() where index < model.entries.count {
            let placed = place(slot)
            guard placed.intersects(dirtyRect) else { continue }
            draw(model.entries[index], in: placed, selected: index == model.selection)
        }
    }

    private func draw(_ entry: SwitcherEntry, in slot: CGRect, selected: Bool) {
        if selected {
            let radius = metrics.tileRadius(icon: layout.iconSide)
            NSColor.white.withAlphaComponent(0.22).setFill()
            NSBezierPath(
                roundedRect: slot.insetBy(
                    dx: -metrics.tilePadding(icon: layout.iconSide),
                    dy: -metrics.tilePadding(icon: layout.iconSide)
                ),
                xRadius: radius,
                yRadius: radius
            ).fill()
        }
        icons.icon(for: entry.application.pid)?
            .draw(in: CGRect(x: slot.minX, y: slot.minY, width: layout.iconSide, height: layout.iconSide))
        guard selected else { return }
        let name = name(model.label(of: entry))
        let area = metrics.nameArea(
            under: slot,
            icon: layout.iconSide,
            text: name.size().width,
            panel: bounds.width
        )
        name.draw(with: area, options: [.usesLineFragmentOrigin])
    }

    private func name(_ text: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byTruncatingTail
        return NSAttributedString(
            string: text,
            attributes: [
                .font: NSFont.systemFont(
                    ofSize: metrics.labelSize(icon: layout.iconSide),
                    weight: .semibold
                ),
                .foregroundColor: NSColor.white.withAlphaComponent(0.95),
                .paragraphStyle: paragraph,
            ]
        )
    }
}
