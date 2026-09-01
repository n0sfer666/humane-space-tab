import Foundation
import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Localisation", .serialized)
struct LocalisationTests {
    @Test("every word the interface asks for exists in every language", arguments: InterfaceLanguage.translated)
    func everyKeyIsTranslated(language: InterfaceLanguage) {
        let bundle = Localised.bundle(for: language)
        #expect(bundle.bundlePath.lowercased().hasSuffix("\(language.rawValue.lowercased()).lproj"))
        for key in UIText.allCases {
            let text = bundle.localizedString(forKey: key.rawValue, value: Self.missing, table: nil)
            #expect(text != Self.missing, "\(language.rawValue) is missing \(key.rawValue)")
            #expect(!text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    /// A translation that drops or renames a placeholder crashes `String(format:)` at the
    /// moment the sentence is shown, which is the worst place to find out.
    @Test("a translated sentence takes the same values as the English one", arguments: InterfaceLanguage.translated)
    func placeholdersSurvive(language: InterfaceLanguage) {
        let bundle = Localised.bundle(for: language)
        for key in UIText.allCases {
            let english = Localised.bundle(for: .english).localizedString(forKey: key.rawValue, value: "", table: nil)
            let text = bundle.localizedString(forKey: key.rawValue, value: "", table: nil)
            #expect(
                Self.placeholders(in: text) == Self.placeholders(in: english),
                "\(language.rawValue) changes the values of \(key.rawValue)"
            )
        }
    }

    @Test("a language the app does not carry is answered in English, not in keys")
    func unknownLanguageFallsBack() {
        let bundle = Localised.bundle(for: .system)
        for key in UIText.allCases {
            #expect(bundle.localizedString(forKey: key.rawValue, value: Self.missing, table: nil) != Self.missing)
        }
    }

    @Test("the chosen language is the one the words come from")
    func choosingALanguageChangesTheWords() {
        let english = Localised.text(.menuSettings)
        Localised.language = .russian
        let russian = Localised.text(.menuSettings)
        Localised.language = .system
        #expect(russian != english)
        #expect(Localised.text(.menuSettings) == english)
    }

    @Test("a sentence with a number in it is filled in, not shown with its placeholder")
    func fillsInValues() {
        let text = Localised.text(.unitMilliseconds, 120)
        #expect(text.contains("120"))
        #expect(!text.contains("%"))
    }

    private static let missing = "\u{0}missing"

    private static func placeholders(in text: String) -> [String] {
        let pattern = try? NSRegularExpression(pattern: "%(?:[0-9]+\\$)?(?:lld|ld|@|d|f)")
        let range = NSRange(text.startIndex..., in: text)
        return pattern?.matches(in: text, range: range).compactMap { match in
            Range(match.range, in: text).map { String(text[$0]) }
        } ?? []
    }
}
