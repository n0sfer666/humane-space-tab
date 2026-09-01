import Testing

@testable import SwitcherCore

@Suite("Interface language")
struct InterfaceLanguageTests {
    @Test("nothing stored means the system decides")
    func nothingStored() {
        #expect(InterfaceLanguage(stored: nil) == .system)
    }

    @Test("a stored language the app no longer carries falls back to the system")
    func nonsenseStored() {
        #expect(InterfaceLanguage(stored: "kl") == .system)
        #expect(InterfaceLanguage(stored: "") == .system)
    }

    @Test("a stored language the app carries is used")
    func storedLanguage() {
        #expect(InterfaceLanguage(stored: "pt-BR") == .portugueseBrazil)
    }

    @Test("every language names itself in its own words")
    func endonyms() {
        #expect(InterfaceLanguage.translated.count == InterfaceLanguage.allCases.count - 1)
        #expect(Set(InterfaceLanguage.allCases.map(\.endonym)).count == InterfaceLanguage.allCases.count)
    }
}
