public struct ApplicationWindow: Sendable, Equatable {
    public let id: WindowIdentifier
    public let visibility: WindowVisibility

    public init(id: WindowIdentifier, visibility: WindowVisibility) {
        self.id = id
        self.visibility = visibility
    }
}
