import AppKit
import Testing

@testable import SwitcherUI

@Suite("Overlay backdrop")
@MainActor
struct OverlayBackdropTests {
    @Test("the ribbon sits inside whichever material the system provides")
    func theRibbonIsInsideTheMaterial() {
        let content = NSView()
        let backdrop = OverlayBackdrop.make(cornerRadius: 26, content: content)
        #expect(content.isDescendant(of: backdrop))
        #expect(content.autoresizingMask == [.width, .height])
        #expect(content.wantsLayer)
    }

    @Test("the glass is frosted, and the scrim the ribbon reads against does not slide with it")
    @available(macOS 26.0, *)
    func theGlassIsFrostedAndScrimmed() throws {
        let content = NSView()
        let glass = try #require(OverlayBackdrop.make(cornerRadius: 26, content: content) as? NSGlassEffectView)
        #expect(glass.style == .regular)
        let scrim = try #require(content.superview)
        #expect(try #require(scrim.layer?.backgroundColor).alpha > 0)
        #expect(scrim.layer?.masksToBounds == true)
    }

    @Test("the material is rounded to the panel's radius")
    func theMaterialIsRounded() {
        let backdrop = OverlayBackdrop.make(cornerRadius: 26, content: NSView())
        if #available(macOS 26.0, *) {
            #expect((backdrop as? NSGlassEffectView)?.cornerRadius == 26)
        } else {
            #expect(backdrop.layer?.cornerRadius == 26)
        }
    }
}
