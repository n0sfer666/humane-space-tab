import AppKit
import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Ribbon preview")
struct RibbonPreviewTests {
    @MainActor
    private func sheet(_ count: Int) -> RibbonPreviewSheet {
        let center = AppearanceCenter(initial: AppearanceBook.standard.adding(name: "Mine")) { _ in }
        let sheet = RibbonPreviewSheet(center: center)
        sheet.loadView()
        sheet.choose(count: count)
        return sheet
    }

    @Test("a run is four steps and then it is over")
    func runsFourSteps() {
        var run = RibbonPreviewRun(count: 10)
        #expect(run.selection == 0)
        for step in 1...RibbonPreviewRun.steps {
            run.step()
            #expect(run.selection == step)
        }
        #expect(!run.isRunning)
        run.step()
        #expect(run.selection == RibbonPreviewRun.steps)
    }

    @Test("a run of one application stays where it is")
    func shortRunWraps() {
        var run = RibbonPreviewRun(count: 1)
        run.step()
        #expect(run.selection == 0)
    }

    @Test("every count the sheet offers can be drawn", arguments: PreviewEntries.counts)
    func drawsEveryCount(count: Int) {
        let sheet = sheet(count)
        #expect(sheet.chosenCount == count)
        sheet.begin()
        sheet.advance()
        #expect(sheet.shownSelection == min(1, count - 1))
    }

    @Test("the sample is laid out the way a session would lay it out")
    func matchesASession() {
        let appearance = Appearance.standard
        let preview = RibbonPreviewView(icons: IconSourceSpy(), appearance: appearance)
        preview.frame = CGRect(origin: .zero, size: RibbonPreviewLayout.stage)
        preview.show(OverlayModel(entries: PreviewEntries.make(100), selection: 0), appearance: appearance)
        let expected = OverlayLayout.compute(
            count: 100,
            screen: RibbonPreviewLayout.stage,
            metrics: OverlayMetrics(appearance: appearance)
        )
        #expect(preview.shownLayout == expected)
        #expect(preview.shownLayout.visible == appearance.carousel.slots)
    }

    @Test("the sample follows the profile being edited")
    func followsTheProfile() {
        let center = AppearanceCenter(initial: AppearanceBook.standard.adding(name: "Mine")) { _ in }
        let sheet = RibbonPreviewSheet(center: center)
        sheet.loadView()
        sheet.choose(count: 5)
        center.edit { $0.with(iconSize: 40) }
        sheet.choose(count: 5)
        #expect(center.appearance.iconSize == 40)
        #expect(!sheet.isRunning)
    }
}
