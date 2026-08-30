import AppKit
import SwitcherCore
import SystemPorts

@MainActor
final class OverlayContentView: NSView {
    private let icons: any ApplicationIconSource
    private let metrics: OverlayMetrics
    private var model = OverlayModel(applications: [], selection: 0)
    private var layout = OverlayLayout.empty
    private var offset = 0

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
        let previous = self.model
        let stepped =
            self.layout == layout && self.offset == offset
            && previous.applications == model.applications
        self.model = model
        self.layout = layout
        self.offset = offset
        guard stepped, let changed = changedArea(from: previous.selection, to: model.selection) else {
            needsDisplay = true
            return
        }
        setNeedsDisplay(changed)
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
        for (index, slot) in layout.slots.enumerated() where index < model.applications.count {
            let placed = place(slot)
            guard placed.intersects(dirtyRect) else { continue }
            draw(model.applications[index], in: placed, selected: index == model.selection)
        }
    }

    private func draw(_ application: SwitchableApplication, in slot: CGRect, selected: Bool) {
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
        icons.icon(for: application.pid)?
            .draw(in: CGRect(x: slot.minX, y: slot.minY, width: layout.iconSide, height: layout.iconSide))
        guard selected else { return }
        name(application.name).draw(with: nameArea(under: slot), options: [.usesLineFragmentOrigin])
    }

    /// Only the selected application is named, so the name is free to be wider than its icon;
    /// it stays centred on that icon and inside the panel.
    private func nameArea(under slot: CGRect) -> CGRect {
        let height = metrics.labelHeight(icon: layout.iconSide)
        let inset = metrics.padding(icon: layout.iconSide)
        let width = min(bounds.width - inset * 2, max(slot.width, layout.iconSide * 2.5))
        return CGRect(
            x: min(max(slot.midX - width / 2, inset), max(bounds.width - width - inset, inset)),
            y: slot.minY + layout.iconSide + metrics.labelGap,
            width: width,
            height: height
        )
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
