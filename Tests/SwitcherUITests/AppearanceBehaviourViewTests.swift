import AppKit
import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Appearance behaviour form")
struct AppearanceBehaviourViewTests {
    @MainActor
    private final class Fixture {
        lazy var center = AppearanceCenter(initial: AppearanceBook.standard.adding(name: "Mine")) { _ in }
        lazy var view = AppearanceBehaviourView(center: center)
    }

    @Test("the form starts on what the profile does")
    func showsActive() {
        let fixture = Fixture()
        #expect(fixture.view.shownPreset == Appearance.standard.selection)
        #expect(fixture.view.isTurning)
        #expect(fixture.view.shownSlots == Appearance.standard.carousel.slots)
    }

    @Test("a preset is kept", arguments: SelectionPreset.allCases)
    func keepsPreset(preset: SelectionPreset) {
        let fixture = Fixture()
        fixture.view.choose(preset)
        #expect(fixture.center.appearance.selection == preset)
        #expect(fixture.view.shownPreset == preset)
    }

    @Test("switching the carousel off takes the slots with it")
    func slotsFollowTheCarousel() {
        let fixture = Fixture()
        fixture.view.turn(false)
        #expect(!fixture.center.appearance.carousel.isEnabled)
        #expect(!fixture.view.slotsAreOn)
        fixture.view.turn(true)
        #expect(fixture.view.slotsAreOn)
    }

    @Test("the slots stay inside what the ribbon can turn in")
    func slotsAreBounded() {
        let fixture = Fixture()
        fixture.view.change(slots: 40)
        #expect(fixture.center.appearance.carousel.slots == CarouselSetting.slotRange.upperBound)
        fixture.view.change(slots: 6)
        #expect(fixture.center.appearance.carousel.slots == 6)
    }

    @Test("the built-in profile is shown, not edited")
    func builtInIsReadOnly() {
        let center = AppearanceCenter(initial: AppearanceBook.standard) { _ in }
        let view = AppearanceBehaviourView(center: center)
        #expect(!view.isEditable)
        view.choose(.spotlight)
        #expect(center.appearance.selection == Appearance.standard.selection)
    }
}
