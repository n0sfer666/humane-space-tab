import SwitcherCore

/// The three materials a profile may ask for, and what its one number is called. The number
/// changes meaning with the style — a scrim darkens glass, an opacity thins a plain panel —
/// so the row beside it is renamed rather than left saying something it no longer means.
enum BackgroundChoice: Int, CaseIterable {
    case glass
    case transparent
    case solid

    init(_ style: BackgroundStyle) {
        switch style {
        case .glass: self = .glass
        case .transparent: self = .transparent
        case .solid: self = .solid
        }
    }

    var title: String {
        switch self {
        case .glass: "Glass"
        case .transparent: "Transparent"
        case .solid: "Background colour"
        }
    }

    var levelTitle: String {
        switch self {
        case .glass: "Shade"
        case .transparent, .solid: "Opacity"
        }
    }

    /// What the style looks like when it is first chosen: the glass as the ribbon has always
    /// drawn it, and a plain panel at full strength, which is the one a person can see.
    var standard: BackgroundStyle {
        switch self {
        case .glass: .standard
        case .transparent: .transparent(opacity: 1)
        case .solid: .solid(opacity: 1)
        }
    }
}
