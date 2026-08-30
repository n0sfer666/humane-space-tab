import AppKit
import SystemPorts

@MainActor
public struct PasteboardTextSink: TextSink {
    public init() {}

    public func write(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
