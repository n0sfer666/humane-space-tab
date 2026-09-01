import AppKit
import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Overlay appearance", .serialized)
struct OverlayAppearanceTests {
    @Test("the ribbon is drawn with the numbers the profile chose")
    func derivesMetrics() {
        let metrics = OverlayMetrics(
            appearance: Appearance(
                iconSize: 64,
                paddingShare: 0.2,
                gapShare: 0.1,
                cornerRadius: 12,
                selection: .spotlight
            )
        )
        #expect(metrics.largestIcon == 64)
        #expect(metrics.paddingShare == 0.2)
        #expect(metrics.gapShare == 0.1)
        #expect(metrics.cornerRadius == 12)
        #expect(metrics.selectedScale == CGFloat(SelectionPreset.spotlight.selectedScale))
        #expect(metrics.dimmed == CGFloat(SelectionPreset.spotlight.dimmed))
    }

    @Test("the frame the profile asked for reaches the drawing")
    func carriesTheFrame() {
        let frame = FrameStyle(width: 2, paddingShare: 0.1, radius: 8)
        let metrics = OverlayMetrics(appearance: Appearance(frame: frame))
        #expect(metrics.frame == frame)
        #expect(OverlayIconFrame.wears(frame, selection: .enlarged, selected: false))
        #expect(OverlayIconFrame.wears(frame, selection: .enlarged, selected: true))
    }

    @Test("the framed preset frames the selection and nothing else")
    func framesTheSelection() {
        let frame = FrameStyle(width: 2, paddingShare: 0.1, radius: 8)
        #expect(OverlayIconFrame.wears(frame, selection: .framed, selected: true))
        #expect(!OverlayIconFrame.wears(frame, selection: .framed, selected: false))
    }

    @Test("no width, no frame")
    func widthOfZeroDrawsNothing() {
        let bare = FrameStyle(width: 0, paddingShare: 0.2, radius: 8)
        #expect(!OverlayIconFrame.wears(bare, selection: .enlarged, selected: true))
    }

    @Test("what ships is what the ribbon drew before there were profiles")
    func standardIsUnchanged() {
        #expect(OverlayMetrics(appearance: .standard) == OverlayMetrics())
    }

    @Test("a smaller icon makes a smaller ribbon, without restarting the app")
    func surfaceTakesAppearance() {
        let surface = OverlayWindowSurface(icons: IconSourceSpy())
        let entries = (0..<3).map { index in
            SwitcherEntry(
                application: SwitchableApplication(
                    pid: ProcessIdentifier(rawValue: Int32(200 + index)),
                    bundleIdentifier: nil,
                    name: "App \(index)",
                    isActive: false,
                    windows: []
                )
            )
        }
        let model = OverlayModel(entries: entries, selection: 0)
        surface.show(model)
        let wide = surface.panel.frame.width
        surface.appearance = Appearance(iconSize: 32)
        surface.show(model)
        #expect(surface.panel.frame.width < wide)
        surface.hide()
    }
}
