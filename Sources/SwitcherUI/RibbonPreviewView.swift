import AppKit
import SwitcherCore
import SystemPorts

/// The ribbon, drawn where it can be looked at. It is the same view the panel puts on
/// screen, laid out for the room the sheet gives it rather than for a screen, so what the
/// sample shows is what the gesture will show — a sample drawn by other code would be free
/// to be wrong.
@MainActor
final class RibbonPreviewView: NSView {
    private let content: OverlayContentView
    private var metrics: OverlayMetrics
    private var backdrop: NSView

    init(icons: any ApplicationIconSource, appearance: Appearance) {
        metrics = OverlayMetrics(appearance: appearance)
        content = OverlayContentView(icons: icons, metrics: metrics)
        backdrop = OverlayBackdrop.make(
            cornerRadius: metrics.cornerRadius,
            background: appearance.background,
            content: content
        )
        super.init(frame: .zero)
        wantsLayer = true
        addSubview(backdrop)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private(set) var shownLayout = OverlayLayout.empty
    private var model = OverlayModel(entries: [], selection: 0)
    private var look = Appearance.standard

    func show(_ model: OverlayModel, appearance: Appearance) {
        self.model = model
        look = appearance
        if OverlayMetrics(appearance: appearance) != metrics {
            metrics = OverlayMetrics(appearance: appearance)
            content.apply(metrics)
            backdrop.removeFromSuperview()
            backdrop = OverlayBackdrop.make(
                cornerRadius: metrics.cornerRadius,
                background: appearance.background,
                content: content
            )
            addSubview(backdrop)
        }
        place()
    }

    /// The sheet sizes the stage after the sample is first drawn, so the ribbon is placed
    /// again whenever the room it has changes — otherwise it is laid out for a stage of
    /// nothing and shows nothing.
    override func layout() {
        super.layout()
        place()
    }

    private func place() {
        let layout = OverlayLayout.compute(count: model.entries.count, screen: bounds.size, metrics: metrics)
        shownLayout = layout
        backdrop.frame = CGRect(
            x: ((bounds.width - layout.size.width) / 2).rounded(),
            y: ((bounds.height - layout.size.height) / 2).rounded(),
            width: layout.size.width,
            height: layout.size.height
        )
        var carrier = content.superview
        while let view = carrier, view !== backdrop {
            view.frame = backdrop.bounds
            carrier = view.superview
        }
        content.frame = CGRect(origin: .zero, size: layout.size)
        content.render(model, layout: layout)
    }
}
