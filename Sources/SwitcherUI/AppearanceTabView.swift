import AppKit
import SwitcherCore

/// The Appearance tab, top to bottom: which profile is being changed, then what it says.
/// The order is the order of the question a person arrives with — first "am I about to
/// change the right one", then "make it bigger".
@MainActor
final class AppearanceTabView: NSView {
    init(center: AppearanceCenter) {
        super.init(frame: .zero)
        let stack = NSStackView(views: [
            AppearanceFormView(center: center),
            Self.rule(),
            AppearanceMetricsView(center: center),
            Self.rule(),
            AppearanceBackgroundView(center: center),
        ])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 20),
            bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private static func rule() -> NSBox {
        let rule = NSBox()
        rule.boxType = .separator
        return rule
    }
}
