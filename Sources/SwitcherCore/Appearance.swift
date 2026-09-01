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
    /// What is left of an icon at its strongest. The ribbon has always drawn its icons a
    /// little short of solid; this is that value, and a person may take it lower still.
    public let iconOpacity: Double
    public let frame: FrameStyle
    public let background: BackgroundStyle
    public let carousel: CarouselSetting
    public let selection: SelectionPreset

    public init(
        iconSize: Double = 100,
        paddingShare: Double = 0.30,
        gapShare: Double = 0.30,
        cornerRadius: Double = 26,
        iconOpacity: Double = 1,
        frame: FrameStyle = .standard,
        background: BackgroundStyle = .standard,
        carousel: CarouselSetting = .standard,
        selection: SelectionPreset = .standard
    ) {
        self.iconSize = iconSize
        self.paddingShare = paddingShare
        self.gapShare = gapShare
        self.cornerRadius = cornerRadius
        self.iconOpacity = iconOpacity
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
        iconOpacity: Double? = nil,
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
            iconOpacity: iconOpacity ?? self.iconOpacity,
            frame: frame ?? self.frame,
            background: background ?? self.background,
            carousel: carousel ?? self.carousel,
            selection: selection ?? self.selection
        )
    }
}

/// A look stored before a setting existed is still a look: every number is read if it is
/// there and taken from `standard` if it is not, so adding one to this type does not throw
/// away the profiles a person has already made.
extension Appearance {
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            iconSize: try values.decodeIfPresent(Double.self, forKey: .iconSize) ?? Self.standard.iconSize,
            paddingShare: try values.decodeIfPresent(Double.self, forKey: .paddingShare)
                ?? Self.standard.paddingShare,
            gapShare: try values.decodeIfPresent(Double.self, forKey: .gapShare) ?? Self.standard.gapShare,
            cornerRadius: try values.decodeIfPresent(Double.self, forKey: .cornerRadius)
                ?? Self.standard.cornerRadius,
            iconOpacity: try values.decodeIfPresent(Double.self, forKey: .iconOpacity)
                ?? Self.standard.iconOpacity,
            frame: try values.decodeIfPresent(FrameStyle.self, forKey: .frame) ?? Self.standard.frame,
            background: try values.decodeIfPresent(BackgroundStyle.self, forKey: .background)
                ?? Self.standard.background,
            carousel: try values.decodeIfPresent(CarouselSetting.self, forKey: .carousel) ?? Self.standard.carousel,
            selection: try values.decodeIfPresent(SelectionPreset.self, forKey: .selection) ?? Self.standard.selection
        )
    }
}
