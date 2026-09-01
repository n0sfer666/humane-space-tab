/// Every profile there is, and which one the ribbon is wearing. The first is the built-in
/// one: it is always there, it cannot be edited or deleted, and it is what a person returns
/// to when their own profile turns out to be a mistake — duplicating it is how a profile of
/// one's own begins. Five more may be kept, which is enough to compare and few enough that
/// the list stays a list.
public struct AppearanceBook: Equatable, Sendable, Codable {
    public static let limit = 5
    public static let builtIn = AppearanceProfile(id: 0, name: "Default", appearance: .standard)
    public static let standard = AppearanceBook()

    public private(set) var profiles: [AppearanceProfile]
    public private(set) var activeID: Int

    public init(profiles: [AppearanceProfile] = [], activeID: Int = builtIn.id) {
        self.profiles = Array(profiles.prefix(Self.limit))
        let known = [Self.builtIn.id] + self.profiles.map(\.id)
        self.activeID = known.contains(activeID) ? activeID : Self.builtIn.id
    }

    public var all: [AppearanceProfile] { [Self.builtIn] + profiles }

    public var active: AppearanceProfile {
        profiles.first { $0.id == activeID } ?? Self.builtIn
    }

    public var isBuiltInActive: Bool { active.id == Self.builtIn.id }

    public var isEditable: Bool { !isBuiltInActive }

    public var hasRoom: Bool { profiles.count < Self.limit }

    public func activating(_ id: Int) -> AppearanceBook {
        AppearanceBook(profiles: profiles, activeID: id)
    }

    /// A new profile carries the settings of the one in front of the person, whichever it
    /// is: pressing add on the built-in profile is the ordinary way out of it.
    public func adding(name: String? = nil) -> AppearanceBook {
        guard hasRoom else { return self }
        let profile = AppearanceProfile(
            id: (profiles.map(\.id).max() ?? Self.builtIn.id) + 1,
            name: unique(name.map(trimmed) ?? copyName(of: active.name), excluding: nil),
            appearance: active.appearance
        )
        return AppearanceBook(profiles: profiles + [profile], activeID: profile.id)
    }

    public func renamingActive(to name: String) -> AppearanceBook {
        let name = trimmed(name)
        guard isEditable, !name.isEmpty, name != active.name else { return self }
        return replacingActive { $0.with(name: unique(name, excluding: self.activeID)) }
    }

    public func updatingActive(_ appearance: Appearance) -> AppearanceBook {
        guard isEditable else { return self }
        return replacingActive { $0.with(appearance: appearance) }
    }

    /// Deleting what is being worn leaves the built-in profile on, so the ribbon is never
    /// without one.
    public func deletingActive() -> AppearanceBook {
        guard isEditable else { return self }
        return AppearanceBook(profiles: profiles.filter { $0.id != activeID }, activeID: Self.builtIn.id)
    }

    public func normalised(screenWidth: Double = AppearanceLimits.referenceWidth) -> AppearanceBook {
        AppearanceBook(
            profiles: profiles.map {
                $0.with(appearance: AppearanceLimits.normalise($0.appearance, screenWidth: screenWidth))
            },
            activeID: activeID
        )
    }

    private func replacingActive(_ change: (AppearanceProfile) -> AppearanceProfile) -> AppearanceBook {
        AppearanceBook(
            profiles: profiles.map { $0.id == activeID ? change($0) : $0 },
            activeID: activeID
        )
    }

    private func trimmed(_ name: String) -> String {
        var value = Substring(name)
        while let first = value.first, first.isWhitespace { value.removeFirst() }
        while let last = value.last, last.isWhitespace { value.removeLast() }
        return String(value)
    }

    /// Two profiles called the same thing are two profiles a person cannot tell apart in a
    /// popup, so a repeated name is numbered rather than refused.
    private func unique(_ name: String, excluding id: Int?) -> String {
        let taken = Set(([Self.builtIn] + profiles).filter { $0.id != id }.map(\.name))
        guard taken.contains(name) else { return name }
        var attempt = 2
        while taken.contains("\(name) \(attempt)") { attempt += 1 }
        return "\(name) \(attempt)"
    }

    private func copyName(of name: String) -> String { "\(name) copy" }
}
