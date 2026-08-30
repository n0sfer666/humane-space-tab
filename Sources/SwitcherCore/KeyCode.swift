public struct KeyCode: Hashable, Sendable {
    public static let tab = KeyCode(rawValue: 48)
    public static let escape = KeyCode(rawValue: 53)

    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}
