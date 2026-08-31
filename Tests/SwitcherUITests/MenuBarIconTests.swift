import AppKit
import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Menu bar icon")
struct MenuBarIconTests {
    @Test("a working switcher and one that needs attention do not share a symbol")
    func distinctSymbols() {
        #expect(MenuBarIcon.symbol(for: .intercepting) != MenuBarIcon.symbol(for: .blocked(canAsk: true)))
        #expect(MenuBarIcon.symbol(for: .blocked(canAsk: true)) == MenuBarIcon.symbol(for: .deaf))
    }

    @Test("every state resolves to an image this system can draw")
    func everyStateDraws() {
        let states: [PermissionState] = [
            .intercepting,
            .observing,
            .deaf,
            .blocked(canAsk: true),
            .blocked(canAsk: false),
        ]
        for state in states {
            #expect(MenuBarIcon.image(for: state) != nil)
        }
    }
}
