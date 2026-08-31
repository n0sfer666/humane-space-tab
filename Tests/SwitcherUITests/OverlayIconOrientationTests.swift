import AppKit
import SwitcherCore
import SystemPorts
import Testing

@testable import SwitcherUI

@MainActor
private final class TwoToneIcons: ApplicationIconSource {
    /// Red on top, blue underneath — an icon that says which way up it was drawn.
    func icon(for process: ProcessIdentifier) -> NSImage? {
        let image = NSImage(size: CGSize(width: 64, height: 64))
        image.lockFocus()
        NSColor.red.setFill()
        CGRect(x: 0, y: 32, width: 64, height: 32).fill()
        NSColor.blue.setFill()
        CGRect(x: 0, y: 0, width: 64, height: 32).fill()
        image.unlockFocus()
        return image
    }

    func prewarm(_ processes: [ProcessIdentifier]) {}
}

@MainActor
@Suite("Overlay icon orientation")
struct OverlayIconOrientationTests {
    private func colour(atFractionDown fraction: CGFloat) throws -> NSColor {
        let view = OverlayContentView(icons: TwoToneIcons(), metrics: OverlayMetrics())
        let layout = OverlayLayout.compute(count: 1, screen: CGSize(width: 1440, height: 900))
        view.frame = CGRect(origin: .zero, size: layout.size)
        view.render(
            OverlayModel(
                entries: [
                    SwitcherEntry(
                        application: SwitchableApplication(
                            pid: ProcessIdentifier(rawValue: 1),
                            bundleIdentifier: nil,
                            name: "Two tone",
                            isActive: true,
                            windows: []
                        ),
                        window: nil
                    )
                ],
                selection: 0
            ),
            layout: layout
        )
        let rep = try #require(view.bitmapImageRepForCachingDisplay(in: view.bounds))
        let context = try #require(NSGraphicsContext(bitmapImageRep: rep))
        view.displayIgnoringOpacity(view.bounds, in: context)
        let slot = layout.slots[0]
        let scale = CGFloat(rep.pixelsWide) / view.bounds.width
        let point = CGPoint(x: slot.midX * scale, y: (slot.minY + slot.width * fraction) * scale)
        return try #require(rep.colorAt(x: Int(point.x), y: Int(point.y))?.usingColorSpace(.deviceRGB))
    }

    /// The ribbon draws into a flipped view, and the drawing call has to be told so: the
    /// variant that ignores it turns every application icon upside down.
    @Test("an icon is drawn the way up it was made")
    func iconsAreNotFlipped() throws {
        let top = try colour(atFractionDown: 0.25)
        let bottom = try colour(atFractionDown: 0.75)
        #expect(top.redComponent > top.blueComponent)
        #expect(bottom.blueComponent > bottom.redComponent)
    }
}
