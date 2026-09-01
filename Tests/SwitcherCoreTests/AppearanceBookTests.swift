import Foundation
import Testing

@testable import SwitcherCore

@Suite("Appearance book")
struct AppearanceBookTests {
    @Test("a fresh book is the built-in profile, and nothing else")
    func startsBuiltIn() {
        let book = AppearanceBook.standard
        #expect(book.profiles.isEmpty)
        #expect(book.active == AppearanceBook.builtIn)
        #expect(book.isBuiltInActive)
        #expect(book.isEditable == false)
        #expect(book.active.appearance == .standard)
    }

    @Test("adding starts from what is on screen and switches to it")
    func addsFromActive() {
        let book = AppearanceBook.standard.adding()
        #expect(book.profiles.count == 1)
        #expect(book.isEditable)
        #expect(book.active.appearance == AppearanceBook.builtIn.appearance)
        #expect(book.active.name == "Default copy")
    }

    @Test("five profiles are kept, and the sixth is refused")
    func stopsAtFive() {
        var book = AppearanceBook.standard
        for _ in 0..<AppearanceBook.limit { book = book.adding() }
        #expect(book.profiles.count == AppearanceBook.limit)
        #expect(book.hasRoom == false)
        let refused = book.adding()
        #expect(refused.profiles.count == AppearanceBook.limit)
        #expect(refused == book)
    }

    @Test("the built-in profile cannot be renamed, edited or deleted")
    func protectsBuiltIn() {
        let book = AppearanceBook.standard
        #expect(book.renamingActive(to: "Mine") == book)
        #expect(book.updatingActive(Appearance(iconSize: 40)) == book)
        #expect(book.deletingActive() == book)
    }

    @Test("renaming keeps the profile on and its settings intact")
    func renames() {
        let book = AppearanceBook.standard.adding().renamingActive(to: "  Night  ")
        #expect(book.active.name == "Night")
        #expect(book.active.appearance == .standard)
        #expect(book.isEditable)
    }

    @Test("an empty name is not a name")
    func refusesEmptyName() {
        let book = AppearanceBook.standard.adding()
        #expect(book.renamingActive(to: "   ") == book)
    }

    @Test("two profiles never share a name")
    func numbersRepeatedNames() {
        let book = AppearanceBook.standard.adding(name: "Night").adding(name: "Night")
        #expect(book.profiles.map(\.name) == ["Night", "Night 2"])
    }

    @Test("editing writes into the profile that is on")
    func updatesActive() {
        let book = AppearanceBook.standard.adding().updatingActive(Appearance(iconSize: 64))
        #expect(book.active.appearance.iconSize == 64)
        #expect(AppearanceBook.builtIn.appearance.iconSize == 100)
    }

    @Test("deleting what is on falls back to the built-in profile")
    func deleteFallsBack() {
        let book = AppearanceBook.standard.adding().deletingActive()
        #expect(book.profiles.isEmpty)
        #expect(book.isBuiltInActive)
    }

    @Test("a profile that is not there cannot be worn")
    func ignoresUnknownActive() {
        #expect(AppearanceBook(profiles: [], activeID: 42).isBuiltInActive)
    }

    @Test("a stored book survives the round trip")
    func codable() throws {
        let book = AppearanceBook.standard.adding(name: "Night").updatingActive(
            Appearance(iconSize: 72, background: .transparent(opacity: 0.5), selection: .native)
        )
        let data = try JSONEncoder().encode(book)
        #expect(try JSONDecoder().decode(AppearanceBook.self, from: data) == book)
    }

    @Test("a look stored before a setting existed keeps the rest of itself")
    func decodesWithoutANewerSetting() throws {
        let stored = Data(
            """
            {"iconSize":72,"paddingShare":0.3,"gapShare":0.3,"cornerRadius":26,
             "frame":{"width":0,"paddingShare":0.2,"radius":8},
             "background":{"glass":{"scrim":0.15}},
             "carousel":{"isEnabled":true,"slots":7},
             "selection":"native"}
            """.utf8
        )
        let appearance = try JSONDecoder().decode(Appearance.self, from: stored)
        #expect(appearance.iconSize == 72)
        #expect(appearance.selection == .native)
        #expect(appearance.iconOpacity == Appearance.standard.iconOpacity)
    }
}
