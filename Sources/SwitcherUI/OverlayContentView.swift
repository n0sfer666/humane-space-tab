import AppKit
import SwitcherCore
import SystemPorts

@MainActor
final class OverlayContentView: NSView {
    private let icons: any ApplicationIconSource
    private let metrics: OverlayMetrics
    private var model = OverlayModel(applications: [], selection: 0)
    private var layout = OverlayLayout.empty

    init(icons: any ApplicationIconSource, metrics: OverlayMetrics) {
        self.icons = icons
        self.metrics = metrics
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override var isFlipped: Bool { true }

    func render(_ model: OverlayModel, layout: OverlayLayout) {
        let previous = self.model
        let stepped = self.layout == layout && previous.applications == model.applications
        self.model = model
        self.layout = layout
        guard stepped, let changed = changedArea(from: previous.selection, to: model.selection) else {
            needsDisplay = true
            return
        }
        setNeedsDisplay(changed)
    }

    /// A step repaints the tile that lost the selection and the one that gained it, not the ribbon.
    private func changedArea(from previous: Int, to current: Int) -> CGRect? {
        let slots = layout.slots
        guard slots.indices.contains(previous), slots.indices.contains(current) else { return nil }
        return slots[previous].union(slots[current]).insetBy(dx: -1, dy: -1)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.28).setFill()
        dirtyRect.fill()
        for (index, slot) in layout.slots.enumerated()
        where index < model.applications.count && slot.intersects(dirtyRect) {
            draw(model.applications[index], in: slot, selected: index == model.selection)
        }
    }

    private func draw(_ application: SwitchableApplication, in slot: CGRect, selected: Bool) {
        if selected {
            NSColor.white.withAlphaComponent(0.22).setFill()
            NSBezierPath(
                roundedRect: slot,
                xRadius: metrics.tileRadius,
                yRadius: metrics.tileRadius
            ).fill()
        }
        let side = (selected ? layout.iconSide * metrics.selectedScale : layout.iconSide).rounded()
        let iconArea = slot.height - metrics.labelGap - metrics.labelHeight(icon: layout.iconSide)
        let icon = CGRect(
            x: (slot.midX - side / 2).rounded(),
            y: (slot.minY + (iconArea - side) / 2).rounded(),
            width: side,
            height: side
        )
        icons.icon(for: application.pid)?.draw(in: icon)
        name(application.name, selected: selected).draw(
            with: CGRect(
                x: slot.minX + 2,
                y: slot.minY + iconArea + metrics.labelGap,
                width: slot.width - 4,
                height: metrics.labelHeight(icon: layout.iconSide)
            ),
            options: [.usesLineFragmentOrigin]
        )
    }

    private func name(_ text: String, selected: Bool) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byTruncatingTail
        return NSAttributedString(
            string: text,
            attributes: [
                .font: NSFont.systemFont(
                    ofSize: metrics.labelSize(icon: layout.iconSide),
                    weight: selected ? .semibold : .regular
                ),
                .foregroundColor: NSColor.white.withAlphaComponent(selected ? 0.95 : 0.55),
                .paragraphStyle: paragraph,
            ]
        )
    }
}
