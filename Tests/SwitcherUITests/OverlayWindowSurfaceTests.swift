import AppKit
import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
private func model(_ count: Int) -> OverlayModel {
    let entries = (0..<count).map { index in
        SwitcherEntry(
            application: SwitchableApplication(
                pid: ProcessIdentifier(rawValue: Int32(100 + index)),
                bundleIdentifier: nil,
                name: "App \(index)",
                isActive: false,
                windows: []
            )
        )
    }
    return OverlayModel(entries: entries, selection: 0)
}

@MainActor
private func ribbon(in window: NSWindow) -> OverlayContentView? {
    var pending = window.contentView.map { [$0] } ?? []
    while let view = pending.popLast() {
        if let ribbon = view as? OverlayContentView { return ribbon }
        pending.append(contentsOf: view.subviews)
    }
    return nil
}

@Suite("Overlay window surface", .serialized)
@MainActor
struct OverlayWindowSurfaceTests {
    /// The defect this pins: a panel kept between sessions belongs to the Spaces the window
    /// server gave it, so after a while the ribbon stops appearing on Spaces it never joined.
    @Test("a session brings a window of its own")
    func renewsTheWindow() {
        let surface = OverlayWindowSurface(icons: IconSourceSpy())
        let first = surface.panel
        surface.show(model(3))
        let second = surface.panel
        surface.hide()
        surface.show(model(3))
        #expect(second !== first)
        #expect(surface.panel !== second)
    }

    @Test("the ribbon travels into the new window")
    func carriesTheRibbon() {
        let surface = OverlayWindowSurface(icons: IconSourceSpy())
        surface.show(model(2))
        let carried = ribbon(in: surface.panel)
        surface.hide()
        surface.show(model(2))
        #expect(carried != nil)
        #expect(ribbon(in: surface.panel) === carried)
    }

    @Test("the window is up while the session is", arguments: [1, 2, 3, 5, 10])
    func ordersTheWindowInAndOut(count: Int) {
        let surface = OverlayWindowSurface(icons: IconSourceSpy())
        surface.show(model(count))
        #expect(surface.panel.isVisible)
        #expect(surface.panel.frame.width > 0)
        surface.hide()
        #expect(!surface.panel.isVisible)
    }
}
