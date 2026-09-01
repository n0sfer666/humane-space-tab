import Testing

@testable import SwitcherCore

@Suite("Appearance limits")
struct AppearanceLimitsTests {
    @Test("what ships is already inside the bounds")
    func standardIsSettled() {
        #expect(AppearanceLimits.normalise(.standard, screenWidth: 1280) == .standard)
    }

    @Test("the icon may not take a quarter of the screen")
    func iconFitsTheScreen() {
        let narrow = AppearanceLimits.iconSize(.standard, screenWidth: 400)
        #expect(narrow.upperBound == 100)
        #expect(AppearanceLimits.iconSize(.standard, screenWidth: 6000).upperBound == 128)
        #expect(AppearanceLimits.normalise(Appearance(iconSize: 9999), screenWidth: 400).iconSize == 100)
    }

    @Test("the margin and the gaps share what is not the icons")
    func spacingCompetes() {
        let roomy = Appearance(gapShare: 0.1)
        let tight = Appearance(gapShare: 0.45)
        #expect(AppearanceLimits.paddingShare(roomy).upperBound > AppearanceLimits.paddingShare(tight).upperBound)
        #expect(
            AppearanceLimits.gapShare(Appearance(paddingShare: 0.1)).upperBound
                > AppearanceLimits.gapShare(Appearance(paddingShare: 0.9)).upperBound)
    }

    @Test("spacing never outgrows the icons it is spacing")
    func spacingStaysBounded() {
        let tamed = AppearanceLimits.normalise(Appearance(paddingShare: 1, gapShare: 1), screenWidth: 1280)
        let slots = Double(tamed.carousel.slots)
        let spacing = 2 * tamed.paddingShare + (slots - 1) * tamed.gapShare
        #expect(spacing <= AppearanceLimits.spacingShare * slots + 0.001)
    }

    @Test("the frame stays inside the margin it is drawn in")
    func frameStaysInside() {
        let asked = Appearance(
            iconSize: 100,
            paddingShare: 0.1,
            frame: FrameStyle(width: 4, paddingShare: 0.4, radius: 10)
        )
        let tamed = AppearanceLimits.normalise(asked, screenWidth: 1280)
        #expect(tamed.frame.paddingShare + tamed.frame.width / tamed.iconSize <= tamed.paddingShare + 0.001)
    }

    @Test("nothing survives being asked for a number that is not one")
    func tamesNonsense() {
        let tamed = AppearanceLimits.normalise(
            Appearance(
                iconSize: .nan,
                paddingShare: .infinity,
                gapShare: -3,
                cornerRadius: 900,
                frame: FrameStyle(width: 40, paddingShare: -1, radius: 400),
                background: .glass(scrim: 5)
            ),
            screenWidth: 1280
        )
        #expect(tamed.iconSize >= AppearanceLimits.smallestIcon)
        #expect(tamed.paddingShare >= 0 && tamed.paddingShare <= 1)
        #expect(tamed.gapShare == 0)
        #expect(tamed.cornerRadius == AppearanceLimits.cornerRadiusRange.upperBound)
        #expect(tamed.frame.width == FrameStyle.widthRange.upperBound)
        #expect(tamed.frame.paddingShare == 0)
        #expect(tamed.frame.radius == FrameStyle.radiusRange.upperBound)
        #expect(tamed.background == .glass(scrim: BackgroundStyle.scrimRange.upperBound))
    }

    @Test("a background carries only the number it can act on")
    func backgroundLevels() {
        #expect(BackgroundStyle.glass(scrim: 0.2).level == 0.2)
        #expect(BackgroundStyle.transparent(opacity: 0.4).with(level: 0.9) == .transparent(opacity: 0.9))
        #expect(BackgroundStyle.solid(opacity: 0.5).with(level: 3) == .solid(opacity: 1))
        #expect(BackgroundStyle.glass(scrim: 0).range == BackgroundStyle.scrimRange)
    }

    @Test("a preset says how the selection is told apart")
    func presets() {
        #expect(SelectionPreset.native.selectedScale == 1)
        #expect(SelectionPreset.native.highlightsSelection)
        #expect(SelectionPreset.enlarged.selectedScale == 1.2)
        #expect(SelectionPreset.enlarged.dimmed == 0.62)
        #expect(SelectionPreset.spotlight.dimmed < SelectionPreset.enlarged.dimmed)
        #expect(SelectionPreset.framed.framesSelection)
        #expect(SelectionPreset.allCases.count == 4)
    }

    @Test("the carousel is never narrower than a turning ribbon")
    func carouselSlots() {
        #expect(CarouselSetting(slots: 1).slots == CarouselSetting.slotRange.lowerBound)
        #expect(CarouselSetting(slots: 99).slots == CarouselSetting.slotRange.upperBound)
        #expect(CarouselSetting.standard.slots == CarouselWindow.span)
    }
}
