/// How the selected entry is told apart from the rest. A preset is a named set of numbers
/// rather than a set of sliders: the ways of showing a selection that read well are few,
/// and the ones that do not are not worth the room they would take in the window.
public enum SelectionPreset: String, CaseIterable, Sendable, Codable {
    /// What macOS draws: nothing grows, and a rounded highlight sits behind the selection.
    case native
    /// The ribbon's own look — the selection grows, its neighbours fade.
    case enlarged
    /// The selection grows further and the rest recede, for a crowded Space.
    case spotlight
    /// Nothing changes size; the selection is the one wearing a frame.
    case framed

    public static let standard = SelectionPreset.enlarged

    public var selectedScale: Double {
        switch self {
        case .native, .framed: 1
        case .enlarged: 1.2
        case .spotlight: 1.3
        }
    }

    public var unselectedScale: Double {
        self == .spotlight ? 0.9 : 1
    }

    public var dimmed: Double {
        switch self {
        case .native, .framed: 1
        case .enlarged: 0.62
        case .spotlight: 0.35
        }
    }

    public var highlightsSelection: Bool {
        self == .native
    }

    public var framesSelection: Bool {
        self == .framed
    }
}
