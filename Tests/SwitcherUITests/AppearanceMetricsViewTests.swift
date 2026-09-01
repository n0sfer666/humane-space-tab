import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Appearance metrics form")
struct AppearanceMetricsViewTests {
    @MainActor
    private final class Fixture {
        lazy var center = AppearanceCenter(initial: AppearanceBook.standard.adding(name: "Mine")) { _ in }
        lazy var view = AppearanceMetricsView(center: center)
    }

    @Test("every row starts on the profile it is editing")
    func showsActive() {
        let fixture = Fixture()
        #expect(fixture.view.shownValues[.iconSize] == Appearance.standard.iconSize)
        #expect(fixture.view.shownValues[.ribbonPadding] == Appearance.standard.paddingShare)
        #expect(fixture.view.isEditable)
    }

    @Test("a change is kept in the profile and shown back")
    func keepsChange() {
        let fixture = Fixture()
        fixture.view.change(.iconSize, to: 64)
        #expect(fixture.center.appearance.iconSize == 64)
        #expect(fixture.view.shownValues[.iconSize] == 64)
    }

    @Test("widening the gaps is what takes the margin's room away")
    func rangesInterlock() {
        let fixture = Fixture()
        let before = fixture.view.shownRanges[.ribbonPadding]?.upperBound ?? 0
        fixture.view.change(.gap, to: 0.45)
        let after = fixture.view.shownRanges[.ribbonPadding]?.upperBound ?? 0
        #expect(after < before)
    }

    @Test("a value past the bound is not kept")
    func clampsBeyondBounds() {
        let fixture = Fixture()
        fixture.view.change(.iconSize, to: 9999)
        #expect(fixture.center.appearance.iconSize <= AppearanceLimits.largestIcon)
        fixture.view.change(.framePadding, to: 1)
        let appearance = fixture.center.appearance
        #expect(appearance.frame.paddingShare <= appearance.paddingShare)
    }

    @Test("the built-in profile is shown but not editable")
    func builtInIsReadOnly() {
        let fixture = Fixture()
        fixture.center.update(fixture.center.book.activating(AppearanceBook.builtIn.id))
        #expect(fixture.view.isEditable == false)
        fixture.view.change(.iconSize, to: 20)
        #expect(fixture.center.appearance == .standard)
    }
}
