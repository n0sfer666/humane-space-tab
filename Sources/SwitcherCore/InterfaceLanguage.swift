/// The language the interface speaks (S19). `.system` is the default and means what every
/// native application means by it: macOS ranks the languages the app has against the ones
/// the user asked for, and the first match wins.
public enum InterfaceLanguage: String, CaseIterable, Sendable {
    case system
    case english = "en"
    case russian = "ru"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case portugueseBrazil = "pt-BR"
    case italian = "it"
    case dutch = "nl"
    case polish = "pl"
    case turkish = "tr"
    case ukrainian = "uk"
    case japanese = "ja"
    case korean = "ko"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"

    /// Every language the app is translated into, `.system` aside.
    public static let translated = allCases.filter { $0 != .system }

    /// A stored value is whatever is on disk: anything unknown means the system's choice.
    public init(stored: String?) {
        self = stored.flatMap(InterfaceLanguage.init(rawValue:)) ?? .system
    }

    /// A language is named in itself, the way macOS names them: a person looking for their
    /// own language finds it without reading the one they do not have. `.system` is not a
    /// language and has no name of its own; the interface supplies one.
    public var endonym: String {
        switch self {
        case .system: ""
        case .english: "English"
        case .russian: "Русский"
        case .german: "Deutsch"
        case .french: "Français"
        case .spanish: "Español"
        case .portugueseBrazil: "Português (Brasil)"
        case .italian: "Italiano"
        case .dutch: "Nederlands"
        case .polish: "Polski"
        case .turkish: "Türkçe"
        case .ukrainian: "Українська"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .chineseSimplified: "简体中文"
        case .chineseTraditional: "繁體中文"
        }
    }
}
