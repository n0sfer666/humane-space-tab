import Carbon.HIToolbox
import Foundation
import SwitcherCore
import SystemPorts

@MainActor
public struct KeyboardLayoutNaming: KeyNaming {
    public init() {}

    /// `UCKeyTranslate` is the only way to ask the layout what a key code prints, so a
    /// shortcut recorded on one layout is labelled by whatever the current one shows —
    /// the same behaviour as the system's own shortcut list. The layout data belongs to
    /// the input source, which has to outlive the translation — and the property is the
    /// `CFData` wrapping the layout, not the layout itself.
    public func name(for key: KeyCode) -> String? {
        guard let source = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue()
        else { return nil }
        return withExtendedLifetime(source) {
            guard let property = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
            else { return nil }
            let data = Unmanaged<CFData>.fromOpaque(property).takeUnretainedValue()
            guard let bytes = CFDataGetBytePtr(data) else { return nil }
            let layout = UnsafeRawPointer(bytes).assumingMemoryBound(to: UCKeyboardLayout.self)
            return Self.translate(key: key.rawValue, layout: layout)
        }
    }

    private static func translate(key: UInt16, layout: UnsafePointer<UCKeyboardLayout>) -> String? {
        var deadKeys: UInt32 = 0
        var length = 0
        var characters = [UniChar](repeating: 0, count: 4)
        let capacity = characters.count
        let status = UCKeyTranslate(
            layout,
            key,
            UInt16(kUCKeyActionDisplay),
            0,
            UInt32(LMGetKbdType()),
            OptionBits(kUCKeyTranslateNoDeadKeysMask),
            &deadKeys,
            capacity,
            &length,
            &characters
        )
        guard status == noErr, length > 0 else { return nil }
        let name = String(utf16CodeUnits: characters, count: length).uppercased()
        guard name.rangeOfCharacter(from: .controlCharacters) == nil,
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return nil }
        return name
    }
}
