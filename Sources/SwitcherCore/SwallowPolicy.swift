/// Decides which events an intercepting tap keeps to itself. Modifier changes always reach
/// other applications, and a key-up is swallowed only when its key-down was.
public struct SwallowPolicy: Sendable {
    private let mode: HotkeyTapMode
    private var swallowedDowns: Set<KeyCode> = []

    public init(mode: HotkeyTapMode) {
        self.mode = mode
    }

    public mutating func swallows(_ decision: HotkeyDecision, of stroke: KeyStroke) -> Bool {
        guard mode == .intercept else { return false }
        switch stroke.phase {
        case .flagsChanged:
            return false
        case .down:
            guard decision != .passThrough else { return false }
            swallowedDowns.insert(stroke.key)
            return true
        case .up:
            return swallowedDowns.remove(stroke.key) != nil
        }
    }
}
