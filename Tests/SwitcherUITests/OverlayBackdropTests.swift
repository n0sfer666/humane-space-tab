import AppKit
import SwitcherCore
import Testing

@testable import SwitcherUI

@Suite("Overlay backdrop")
@MainActor
struct OverlayBackdropTests {
    @Test("the ribbon sits inside whichever material the system provides")
    func theRibbonIsInsideTheMaterial() {
        let content = NSView()
        let backdrop = OverlayBackdrop.make(cornerRadius: 26, background: .standard, content: content)
        #expect(content.isDescendant(of: backdrop))
        #expect(content.autoresizingMask == [.width, .height])
        #expect(content.wantsLayer)
    }

    @Test("the glass is frosted, and the scrim the ribbon reads against does not slide with it")
    @available(macOS 26.0, *)
    func theGlassIsFrostedAndScrimmed() throws {
        let content = NSView()
        let glass = try #require(
            OverlayBackdrop.make(cornerRadius: 26, background: .standard, content: content) as? NSGlassEffectView)
        #expect(glass.style == .regular)
        let scrim = try #require(content.superview)
        #expect(try #require(scrim.layer?.backgroundColor).alpha > 0)
        #expect(scrim.layer?.masksToBounds == true)
    }

    @Test("the material is rounded to the panel's radius")
    func theMaterialIsRounded() {
        let backdrop = OverlayBackdrop.make(cornerRadius: 26, background: .standard, content: NSView())
        if #available(macOS 26.0, *) {
            #expect((backdrop as? NSGlassEffectView)?.cornerRadius == 26)
        } else {
            #expect(backdrop.layer?.cornerRadius == 26)
        }
    }

    @Test("transparent lets the desktop through at the opacity asked for")
    func transparentIsThin() {
        let content = NSView()
        let backdrop = OverlayBackdrop.make(cornerRadius: 26, background: .transparent(opacity: 0.4), content: content)
        #expect(abs(backdrop.alphaValue - 0.4) < 0.001)
        #expect(!(backdrop is NSVisualEffectView))
        #expect(content.isDescendant(of: backdrop))
    }

    @Test("a solid panel is painted, not blurred")
    func solidIsPainted() throws {
        let content = NSView()
        let backdrop = OverlayBackdrop.make(cornerRadius: 26, background: .solid(opacity: 0.8), content: content)
        let painted = try #require(backdrop.layer?.backgroundColor.flatMap { NSColor(cgColor: $0) })
        #expect(!(backdrop is NSVisualEffectView))
        #expect(painted.alphaComponent > 0.5)
        #expect(backdrop.layer?.cornerRadius == 26)
        #expect(content.isDescendant(of: backdrop))
    }
}
