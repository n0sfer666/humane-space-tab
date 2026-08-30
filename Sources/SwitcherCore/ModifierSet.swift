public struct ModifierSet: OptionSet, Hashable, Sendable {
    public static let command = ModifierSet(rawValue: 1 << 0)
    public static let shift = ModifierSet(rawValue: 1 << 1)
    public static let control = ModifierSet(rawValue: 1 << 2)
    public static let option = ModifierSet(rawValue: 1 << 3)
    /// Every bit this type gives a meaning to. A stored value carrying anything else came
    /// from a hand-edited file, and the extra bits can never arrive from a real keystroke.
    public static let known: ModifierSet = [.command, .shift, .control, .option]

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}
