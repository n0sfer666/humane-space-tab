import SwitcherCore

/// How the two screen choices are named in the popup (S08).
enum ScreenChoiceTitle {
    static func key(for choice: OverlayScreenChoice) -> UIText {
        switch choice {
        case .focused: .screenFocused
        case .pointer: .screenPointer
        }
    }
}
