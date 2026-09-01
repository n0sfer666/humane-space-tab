/// A named set of appearance settings. The name is the person's; the identifier is the
/// book's, and stays with the profile through renames so the active one survives them.
public struct AppearanceProfile: Equatable, Sendable, Codable, Identifiable {
    public let id: Int
    public let name: String
    public let appearance: Appearance

    public init(id: Int, name: String, appearance: Appearance) {
        self.id = id
        self.name = name
        self.appearance = appearance
    }

    public func with(name: String? = nil, appearance: Appearance? = nil) -> AppearanceProfile {
        AppearanceProfile(id: id, name: name ?? self.name, appearance: appearance ?? self.appearance)
    }
}
