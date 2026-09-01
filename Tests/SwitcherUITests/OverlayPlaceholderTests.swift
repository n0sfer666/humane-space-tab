import AppKit
import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Overlay placeholder")
struct OverlayPlaceholderTests {
    @Test("an empty Space gets a panel wide enough for the sentence")
    func layoutFitsTheSentence() {
        let metrics = OverlayMetrics()
        let layout = OverlayPlaceholder.layout(metrics)
        let padding = metrics.padding(icon: metrics.largestIcon)
        let text = OverlayName.text(
            OverlayPlaceholder.sentence,
            size: metrics.labelSize(icon: metrics.largestIcon)
        )
        #expect(layout.slots.isEmpty)
        #expect(layout.visible == 0)
        #expect(layout.size.width >= text.size().width + padding * 2)
        #expect(layout.size.height >= text.size().height)
    }

    @Test("the panel of an empty Space is the profile's panel, not an empty rect")
    func surfaceShowsThePlaceholder() {
        let surface = OverlayWindowSurface(icons: IconSourceSpy())
        surface.show(OverlayModel(entries: [], selection: 0))
        #expect(surface.panel.frame.width == OverlayPlaceholder.layout(OverlayMetrics()).size.width)
        #expect(surface.panel.frame.height > 0)
        surface.hide()
    }

    @Test("a smaller icon makes a smaller sentence")
    func sentenceFollowsTheProfile() {
        let small = OverlayPlaceholder.layout(OverlayMetrics(appearance: Appearance(iconSize: 32)))
        let large = OverlayPlaceholder.layout(OverlayMetrics(appearance: Appearance(iconSize: 100)))
        #expect(small.size.width < large.size.width)
    }
}
