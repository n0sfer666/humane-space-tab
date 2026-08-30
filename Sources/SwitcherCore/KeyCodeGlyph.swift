extension KeyCode {
    /// Only the keys whose label is the same on every layout live here; everything else
    /// has to be asked of the current keyboard layout, because the glyph printed on a key
    /// is a property of the layout and not of the virtual key code.
    public var glyph: String? { Self.glyphs[rawValue] }

    private static let glyphs: [UInt16: String] = [
        36: "↩", 48: "⇥", 49: "␣", 51: "⌫", 53: "⎋", 71: "⌧", 76: "⌤",
        115: "↖", 116: "⇞", 117: "⌦", 119: "↘", 121: "⇟",
        123: "←", 124: "→", 125: "↓", 126: "↑",
        122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6", 98: "F7",
        100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12", 105: "F13",
        107: "F14", 113: "F15", 106: "F16", 64: "F17", 79: "F18", 80: "F19", 90: "F20",
    ]
}
