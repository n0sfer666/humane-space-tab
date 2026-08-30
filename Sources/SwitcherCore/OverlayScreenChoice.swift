public enum OverlayScreenChoice: String, CaseIterable, Sendable {
    case focused
    case pointer

    /// A stored value is whatever is on disk: anything unknown means the default.
    public init(stored: String?) {
        self = stored.flatMap(OverlayScreenChoice.init(rawValue:)) ?? .focused
    }

    public var label: String {
        switch self {
        case .focused: "Screen with keyboard focus"
        case .pointer: "Screen with the pointer"
        }
    }
}
