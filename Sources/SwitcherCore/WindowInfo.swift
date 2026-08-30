public struct WindowInfo: Sendable, Equatable {
    public let id: WindowIdentifier
    public let owner: ProcessIdentifier
    public let layer: Int
    public let alpha: Double
    public let isOnScreen: Bool

    public init(id: WindowIdentifier, owner: ProcessIdentifier, layer: Int, alpha: Double, isOnScreen: Bool) {
        self.id = id
        self.owner = owner
        self.layer = layer
        self.alpha = alpha
        self.isOnScreen = isOnScreen
    }

    public var isReal: Bool {
        layer == 0 && alpha > 0
    }

    public func owned(by owner: ProcessIdentifier) -> WindowInfo {
        WindowInfo(id: id, owner: owner, layer: layer, alpha: alpha, isOnScreen: isOnScreen)
    }
}
