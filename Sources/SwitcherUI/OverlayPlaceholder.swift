import AppKit

/// What the ribbon says on a Space with nothing open on it (S18). The sentence is the whole
/// panel: there is no icon to draw, and the answer is the app's own rather than the system
/// switcher the key would otherwise reach.
@MainActor
enum OverlayPlaceholder {
    static let sentence = "Nothing open on this Space"

    static func layout(_ metrics: OverlayMetrics) -> OverlayLayout {
        let padding = metrics.padding(icon: metrics.largestIcon)
        let text = text(metrics).size()
        return OverlayLayout(
            size: CGSize(
                width: (text.width + padding * 2).rounded(.up),
                height: (text.height + padding * 2).rounded(.up)
            ),
            iconSide: 0,
            visible: 0,
            slots: []
        )
    }

    static func draw(_ metrics: OverlayMetrics, in bounds: CGRect) {
        let name = text(metrics)
        let height = name.size().height
        OverlayName.draw(
            name,
            in: CGRect(
                x: bounds.minX,
                y: (bounds.midY - height / 2).rounded(),
                width: bounds.width,
                height: height
            )
        )
    }

    private static func text(_ metrics: OverlayMetrics) -> NSAttributedString {
        OverlayName.text(sentence, size: metrics.labelSize(icon: metrics.largestIcon))
    }
}
