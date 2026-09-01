/// Everything about the ribbon a person is allowed to choose. It is a plain value: the form
/// edits a copy, the profile it belongs to holds it, and the ribbon reads it — no part of the
/// drawing code keeps a setting of its own.
public struct Appearance: Equatable, Sendable, Codable {
    public static let standard = Appearance()

    /// The icon at its largest; a crowded ribbon still shrinks below this to fit the screen.
    public let iconSize: Double
    /// The room between the icons and the panel's edge, as a share of the icon.
    public let paddingShare: Double
    /// The room between two icons, as a share of the icon.
    public let gapShare: Double
    public let cornerRadius: Double
    public let frame: FrameStyle
    public let background: BackgroundStyle
    public let carousel: CarouselSetting
    public let selection: SelectionPreset

    public init(
        iconSize: Double = 100,
        paddingShare: Double = 0.30,
        gapShare: Double = 0.30,
        cornerRadius: Double = 26,
        frame: FrameStyle = .standard,
        background: BackgroundStyle = .standard,
        carousel: CarouselSetting = .standard,
        selection: SelectionPreset = .standard
    ) {
        self.iconSize = iconSize
        self.paddingShare = paddingShare
        self.gapShare = gapShare
        self.cornerRadius = cornerRadius
        self.frame = frame
        self.background = background
        self.carousel = carousel
        self.selection = selection
    }

    public func with(
        iconSize: Double? = nil,
        paddingShare: Double? = nil,
        gapShare: Double? = nil,
        cornerRadius: Double? = nil,
        frame: FrameStyle? = nil,
        background: BackgroundStyle? = nil,
        carousel: CarouselSetting? = nil,
        selection: SelectionPreset? = nil
    ) -> Appearance {
        Appearance(
            iconSize: iconSize ?? self.iconSize,
            paddingShare: paddingShare ?? self.paddingShare,
            gapShare: gapShare ?? self.gapShare,
            cornerRadius: cornerRadius ?? self.cornerRadius,
            frame: frame ?? self.frame,
            background: background ?? self.background,
            carousel: carousel ?? self.carousel,
            selection: selection ?? self.selection
        )
    }
}
