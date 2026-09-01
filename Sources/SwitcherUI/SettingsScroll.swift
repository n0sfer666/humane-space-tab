import AppKit

/// A settings column that is taller than the window may be. It scrolls, starting at the top,
/// and stops growing at the height a small display can show under the menu bar.
@MainActor
enum SettingsScroll {
    static func make(_ content: NSView, tallest: CGFloat) -> NSScrollView {
        let size = content.fittingSize
        let document = TopDownView(frame: CGRect(origin: .zero, size: size))
        content.frame = document.bounds
        content.autoresizingMask = [.width, .height]
        document.addSubview(content)
        let scroll = NSScrollView()
        scroll.documentView = document
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        scroll.drawsBackground = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.widthAnchor.constraint(equalToConstant: size.width + scrollerWidth(size, tallest: tallest)),
            scroll.heightAnchor.constraint(equalToConstant: min(size.height, tallest)),
        ])
        return scroll
    }

    private static func scrollerWidth(_ size: CGSize, tallest: CGFloat) -> CGFloat {
        guard size.height > tallest else { return 0 }
        return NSScroller.scrollerWidth(for: .regular, scrollerStyle: .overlay)
    }
}
