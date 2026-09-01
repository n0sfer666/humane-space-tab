import AppKit
import SwitcherCore

/// The Appearance tab, top to bottom: which profile is being changed, then the sizes, then
/// what the panel is made of, then how the row behaves. The order is the order of the
/// question a person arrives with — first "am I about to change the right one", then "make
/// it bigger". The whole column is taller than a laptop screen, so it scrolls rather than
/// pushing the window off the display.
@MainActor
final class AppearanceTabView: NSView {
    private let center: AppearanceCenter
    /// Past this the window would be taller than the room a 13-inch display leaves under
    /// the menu bar, and the settings would open half off the screen.
    private static let tallest: CGFloat = 560

    init(center: AppearanceCenter) {
        self.center = center
        super.init(frame: .zero)
        let sample = NSButton(title: "Show a sample…", target: nil, action: nil)
        sample.bezelStyle = .rounded
        sample.target = self
        sample.action = #selector(showSample)
        let stack = NSStackView(views: [
            AppearanceFormView(center: center),
            sample,
            Self.rule(),
            AppearanceMetricsView(center: center),
            Self.rule(),
            AppearanceBackgroundView(center: center),
            Self.rule(),
            AppearanceBehaviourView(center: center),
        ])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        install(stack)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    @objc
    private func showSample() {
        guard let host = window?.contentViewController else { return }
        host.presentAsSheet(RibbonPreviewSheet(center: center))
    }

    private func install(_ stack: NSStackView) {
        let scroll = SettingsScroll.make(stack, tallest: Self.tallest)
        addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
        ])
    }

    private static func rule() -> NSBox {
        let rule = NSBox()
        rule.boxType = .separator
        return rule
    }
}
