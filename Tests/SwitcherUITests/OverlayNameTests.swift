import AppKit
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Overlay name")
struct OverlayNameTests {
    private static let title =
        "Very Long Document Title That No Ribbon Could Ever Fit — final revision (2).md"

    @Test("a title too long for its box is cut down to one line inside it")
    func aLongTitleStaysOnOneLine() {
        let name = OverlayName.text(Self.title, size: 13)
        let area = CGRect(x: 0, y: 0, width: 120, height: 18)
        let drawn = name.boundingRect(with: area.size, options: OverlayName.options)
        #expect(drawn.height <= area.height)
        #expect(drawn.width <= area.width)
    }

    @Test("what a truncated title keeps is both of its ends")
    func bothEndsSurvive() {
        let name = OverlayName.text(Self.title, size: 13)
        #expect(name.string.hasPrefix("Very"))
        let paragraph = name.attribute(.paragraphStyle, at: 0, effectiveRange: nil)
        #expect((paragraph as? NSParagraphStyle)?.lineBreakMode == .byTruncatingMiddle)
    }

    @Test("a title that fits keeps its own width")
    func aShortTitleIsNotTouched() {
        let name = OverlayName.text("Notes", size: 13)
        let area = CGSize(width: 200, height: 18)
        let drawn = name.boundingRect(with: area, options: OverlayName.options)
        #expect(drawn.height <= area.height)
        #expect(drawn.width < area.width)
    }
}
