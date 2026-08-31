import AppKit

/// The name under the selected icon. A window title is as long as the document someone
/// opened, and its ends carry the meaning: the document at the front, the application at
/// the back. What a title can spare is its middle, so that is where it is cut.
@MainActor
enum OverlayName {
    static let options: NSString.DrawingOptions = [.usesLineFragmentOrigin, .truncatesLastVisibleLine]

    static func text(_ text: String, size: CGFloat) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byTruncatingMiddle
        return NSAttributedString(
            string: text,
            attributes: [
                .font: NSFont.systemFont(ofSize: size, weight: .semibold),
                .foregroundColor: NSColor.white.withAlphaComponent(0.95),
                .paragraphStyle: paragraph,
            ]
        )
    }

    static func draw(_ name: NSAttributedString, in area: CGRect) {
        name.draw(with: area, options: options)
    }
}
