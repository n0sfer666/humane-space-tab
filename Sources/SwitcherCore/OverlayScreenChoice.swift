public enum OverlayScreenChoice: String, CaseIterable, Sendable {
    case focused
    case pointer

    /// A stored value is whatever is on disk: anything unknown means the default.
    public init(stored: String?) {
        self = stored.flatMap(OverlayScreenChoice.init(rawValue:)) ?? .focused
    }

}
