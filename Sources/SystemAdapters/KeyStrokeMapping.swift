import CoreGraphics
import SwitcherCore

extension ModifierSet {
    public init(eventFlags: CGEventFlags) {
        var modifiers = ModifierSet()
        if eventFlags.contains(.maskCommand) { modifiers.insert(.command) }
        if eventFlags.contains(.maskShift) { modifiers.insert(.shift) }
        if eventFlags.contains(.maskControl) { modifiers.insert(.control) }
        if eventFlags.contains(.maskAlternate) { modifiers.insert(.option) }
        self = modifiers
    }
}

extension KeyPhase {
    public init?(eventType: CGEventType) {
        switch eventType {
        case .keyDown: self = .down
        case .keyUp: self = .up
        case .flagsChanged: self = .flagsChanged
        default: return nil
        }
    }
}

extension KeyStroke {
    public init?(event: CGEvent, type: CGEventType) {
        guard let phase = KeyPhase(eventType: type) else { return nil }
        let code = event.getIntegerValueField(.keyboardEventKeycode)
        self.init(
            key: KeyCode(rawValue: UInt16(truncatingIfNeeded: code)),
            modifiers: ModifierSet(eventFlags: event.flags),
            phase: phase
        )
    }
}
