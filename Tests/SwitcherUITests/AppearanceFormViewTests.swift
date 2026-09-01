import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Appearance form")
struct AppearanceFormViewTests {
    @MainActor
    private final class Fixture {
        var saved: [AppearanceBook] = []
        lazy var center = AppearanceCenter(initial: .standard) { [unowned self] in self.saved.append($0) }
        lazy var view = AppearanceFormView(center: center)
    }

    @Test("the built-in profile is shown, and shown as untouchable")
    func startsBuiltIn() {
        let fixture = Fixture()
        #expect(fixture.view.shownProfiles == [AppearanceBook.builtIn.name])
        #expect(fixture.view.shownName == AppearanceBook.builtIn.name)
        #expect(fixture.view.canRename == false)
        #expect(fixture.view.canDelete == false)
        #expect(fixture.view.canDuplicate)
    }

    @Test("duplicating gives a profile that can be edited, and says how many are left")
    func duplicates() {
        let fixture = Fixture()
        fixture.view.duplicateActive()
        #expect(fixture.view.shownProfiles.count == 2)
        #expect(fixture.view.canRename)
        #expect(fixture.view.canDelete)
        #expect(fixture.view.shownNote.contains("4 more"))
        #expect(fixture.saved.count == 1)
    }

    @Test("the form stops offering a sixth profile")
    func stopsAtFive() {
        let fixture = Fixture()
        for _ in 0..<AppearanceBook.limit { fixture.view.duplicateActive() }
        #expect(fixture.view.canDuplicate == false)
        #expect(fixture.view.shownNote.contains("Delete one"))
    }

    @Test("renaming shows the new name in the list")
    func renames() {
        let fixture = Fixture()
        fixture.view.duplicateActive()
        fixture.view.rename(to: "Night")
        #expect(fixture.view.shownName == "Night")
        #expect(fixture.view.shownProfiles.contains("Night"))
    }

    @Test("a name the book refuses does not stay in the field")
    func refusesEmptyName() {
        let fixture = Fixture()
        fixture.view.duplicateActive()
        let before = fixture.view.shownName
        fixture.view.rename(to: "   ")
        #expect(fixture.view.shownName == before)
    }

    @Test("choosing from the list is what puts a profile on")
    func chooses() {
        let fixture = Fixture()
        fixture.view.duplicateActive()
        fixture.view.choose(at: 0)
        #expect(fixture.center.book.isBuiltInActive)
        #expect(fixture.view.canRename == false)
    }

    @Test("deleting the profile that is on goes back to the built-in one")
    func deletes() {
        let fixture = Fixture()
        fixture.view.duplicateActive()
        fixture.view.deleteActive()
        #expect(fixture.view.shownProfiles == [AppearanceBook.builtIn.name])
        #expect(fixture.center.book.isBuiltInActive)
    }
}
