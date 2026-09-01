import AppKit
import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Appearance background form")
struct AppearanceBackgroundViewTests {
    @MainActor
    private final class Fixture {
        lazy var center = AppearanceCenter(initial: AppearanceBook.standard.adding(name: "Mine")) { _ in }
        lazy var view = AppearanceBackgroundView(center: center)
    }

    @Test("the form starts on the style the profile is wearing")
    func showsActive() {
        let fixture = Fixture()
        #expect(fixture.view.shownChoice == .glass)
        #expect(fixture.view.shownLevel == BackgroundStyle.standard.level)
        #expect(fixture.view.isEditable)
    }

    @Test("choosing a style keeps it, and the number is renamed to what it now means")
    func picksStyle() {
        let fixture = Fixture()
        fixture.view.choose(.transparent)
        #expect(fixture.center.appearance.background == .transparent(opacity: 1))
        #expect(fixture.view.shownLevelTitle == BackgroundChoice.transparent.levelTitle)
        #expect(fixture.view.shownLevelTitle != BackgroundChoice.glass.levelTitle)
    }

    @Test("each style bounds its own number")
    func boundsLevel() {
        let fixture = Fixture()
        fixture.view.change(level: 5)
        #expect(fixture.center.appearance.background == .glass(scrim: BackgroundStyle.scrimRange.upperBound))
        fixture.view.choose(.solid)
        fixture.view.change(level: 0)
        #expect(fixture.center.appearance.background == .solid(opacity: BackgroundStyle.opacityRange.lowerBound))
    }

    @Test("the built-in profile is shown, not edited")
    func builtInIsReadOnly() {
        let center = AppearanceCenter(initial: AppearanceBook.standard) { _ in }
        let view = AppearanceBackgroundView(center: center)
        #expect(!view.isEditable)
        view.choose(.solid)
        #expect(center.appearance.background == Appearance.standard.background)
    }
}
