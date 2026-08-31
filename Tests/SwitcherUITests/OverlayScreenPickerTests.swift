import CoreGraphics
import SwitcherCore
import Testing

@testable import SwitcherUI

@Suite("Overlay screen picker")
struct OverlayScreenPickerTests {
    private let frames = [
        CGRect(x: 0, y: 0, width: 1440, height: 900),
        CGRect(x: 1440, y: 0, width: 2560, height: 1440),
    ]

    @Test("keyboard focus wins over where the pointer happens to be")
    func focusedIgnoresPointer() {
        let index = OverlayScreenPicker.index(
            for: .focused,
            pointer: CGPoint(x: 2000, y: 500),
            frames: frames,
            focused: 0
        )
        #expect(index == 0)
    }

    @Test("the pointer choice picks the display under the pointer")
    func pointerPicksItsDisplay() {
        let index = OverlayScreenPicker.index(
            for: .pointer,
            pointer: CGPoint(x: 2000, y: 500),
            frames: frames,
            focused: 0
        )
        #expect(index == 1)
    }

    @Test("a pointer outside every display falls back to keyboard focus")
    func pointerOffscreenFallsBack() {
        let index = OverlayScreenPicker.index(
            for: .pointer,
            pointer: CGPoint(x: -10, y: -10),
            frames: frames,
            focused: 1
        )
        #expect(index == 1)
    }

    @Test("keyboard focus the system will not name falls back to the pointer")
    func focusedUnknownFallsBackToPointer() {
        let index = OverlayScreenPicker.index(
            for: .focused,
            pointer: CGPoint(x: 2000, y: 500),
            frames: frames,
            focused: nil
        )
        #expect(index == 1)
    }

    @Test("neither signal available still puts the ribbon on the primary display")
    func noSignalPicksPrimary() {
        for choice in [OverlayScreenChoice.focused, .pointer] {
            let index = OverlayScreenPicker.index(
                for: choice,
                pointer: CGPoint(x: -10, y: -10),
                frames: frames,
                focused: nil
            )
            #expect(index == 0)
        }
    }

    @Test("an index no longer backed by a display is discarded, not returned")
    func staleFocusIsDiscarded() {
        let index = OverlayScreenPicker.index(
            for: .focused,
            pointer: CGPoint(x: 2000, y: 500),
            frames: frames,
            focused: 7
        )
        #expect(index == 1)
    }

    @Test("no displays at all resolves to nothing")
    func noDisplays() {
        #expect(OverlayScreenPicker.index(for: .pointer, pointer: .zero, frames: [], focused: nil) == nil)
        #expect(OverlayScreenPicker.index(for: .focused, pointer: .zero, frames: [], focused: 0) == nil)
    }
}
