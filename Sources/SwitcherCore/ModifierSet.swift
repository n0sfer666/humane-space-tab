public struct ModifierSet: OptionSet, Hashable, Sendable {
    public static let command = ModifierSet(rawValue: 1 << 0)
    public static let shift = ModifierSet(rawValue: 1 << 1)
    public static let control = ModifierSet(rawValue: 1 << 2)
    public static let option = ModifierSet(rawValue: 1 << 3)

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}
