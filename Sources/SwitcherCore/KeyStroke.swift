public struct KeyStroke: Hashable, Sendable {
    public let key: KeyCode
    public let modifiers: ModifierSet
    public let phase: KeyPhase

    public init(key: KeyCode, modifiers: ModifierSet, phase: KeyPhase) {
        self.key = key
        self.modifiers = modifiers
        self.phase = phase
    }
}
