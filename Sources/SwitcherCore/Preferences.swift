public struct Preferences: Equatable, Sendable {
    public static let standard = Preferences()
    public static let delayRange: ClosedRange<Double> = 0...0.5
    public static let delayStep = 0.01

    public let revealDelay: Double
    public let overlayScreen: OverlayScreenChoice
    public let usesPrivateSpaceLayer: Bool
    public let switchesWindows: Bool
    public let shortcut: Shortcut
    public let windowShortcut: Shortcut

    /// The delay is normalised rather than validated: the store is a file the user can
    /// edit by hand, and nonsense there must produce a working app, not a wedged one. It
    /// is also quantised, so the slider position and the stored number are the same value
    /// and the settings window never shows a delay the app is not using. A shortcut the
    /// rules refuse is normalised the same way, to the default.
    public init(
        revealDelay: Double = 0.12,
        overlayScreen: OverlayScreenChoice = .focused,
        usesPrivateSpaceLayer: Bool = false,
        switchesWindows: Bool = false,
        shortcut: Shortcut = .commandTab,
        windowShortcut: Shortcut = .commandGrave
    ) {
        self.revealDelay = Self.normalised(revealDelay)
        self.overlayScreen = overlayScreen
        self.usesPrivateSpaceLayer = usesPrivateSpaceLayer
        self.switchesWindows = switchesWindows
        self.shortcut = ShortcutRule.normalised(shortcut)
        self.windowShortcut = ShortcutRule.normalised(windowShortcut, fallback: .commandGrave)
    }

    /// A pair that collides is left as it is rather than rewritten: the interpreter already
    /// resolves it in a fixed order, and a second silent rule over a value the user typed
    /// into the file by hand would be worse than a shortcut that does nothing.
    public var shortcuts: ShortcutSet {
        ShortcutSet(applications: shortcut, frontWindows: windowShortcut)
    }

    private static func normalised(_ delay: Double) -> Double {
        guard delay.isFinite else { return 0.12 }
        let clamped = min(max(delay, delayRange.lowerBound), delayRange.upperBound)
        return (clamped / delayStep).rounded() * delayStep
    }
}
