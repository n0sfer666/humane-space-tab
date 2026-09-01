import Foundation
import SwitcherCore

/// The one way a view gets a word (S19). A language the user chose is looked up in its own
/// `.lproj`; anything the choice does not carry falls back to English, so a missing
/// translation shows a sentence rather than a key.
@MainActor
public enum Localised {
    public static var language: InterfaceLanguage = .system {
        didSet { chosen = Self.bundle(for: language) }
    }

    private static var chosen = Bundle.module
    private static let english = Self.bundle(for: .english)

    public static func text(_ key: UIText) -> String {
        chosen.localizedString(
            forKey: key.rawValue,
            value: english.localizedString(forKey: key.rawValue, value: key.rawValue, table: nil),
            table: nil
        )
    }

    public static func text(_ key: UIText, _ argument: some CVarArg) -> String {
        String(format: text(key), locale: .current, argument)
    }

    /// The build lowercases the region a language carries — `pt-BR` is shipped as
    /// `pt-br.lproj` — so the folder is found by name rather than asked for by tag.
    static func bundle(for language: InterfaceLanguage) -> Bundle {
        guard language != .system,
            let root = Bundle.module.resourceURL,
            let names = try? FileManager.default.contentsOfDirectory(atPath: root.path),
            let name = names.first(where: { $0.lowercased() == "\(language.rawValue).lproj".lowercased() }),
            let bundle = Bundle(url: root.appendingPathComponent(name))
        else { return .module }
        return bundle
    }
}
