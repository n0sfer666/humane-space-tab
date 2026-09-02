import AppKit
import CoreGraphics
import Darwin
import Foundation
import SwitcherCore
import SystemPorts

/// Secure input is the one thing that silences a healthy tap: while it is on, the window
/// server hands key presses to nobody, and every check the app can make on itself still
/// passes. The session dictionary names the process holding it, which is the difference
/// between telling the user something is wrong and telling them what to close.
public final class CGSessionSecureInput: SecureInputMonitor {
    private static let key = "kCGSSessionSecureInputPID"
    private static let pathBufferSize = 4 * Int(PATH_MAX)

    public init() {}

    public var holder: SecureInputHolder? {
        guard let session = CGSessionCopyCurrentDictionary() as? [String: Any],
            let number = session[Self.key] as? NSNumber
        else { return nil }
        let process = ProcessIdentifier(rawValue: number.int32Value)
        guard process.rawValue > 0 else { return nil }
        return SecureInputHolder(process: process, name: Self.name(of: process))
    }

    /// An application answers with the name it shows in the menu bar. The usual holder is
    /// `loginwindow`, which is no application at all, so anything else is named by the last
    /// component of its executable — the word a person will recognise in Activity Monitor.
    private static func name(of process: ProcessIdentifier) -> String? {
        let running = NSRunningApplication(processIdentifier: process.rawValue)
        if let name = running?.localizedName { return name }
        var buffer = [UInt8](repeating: 0, count: pathBufferSize)
        let written = proc_pidpath(process.rawValue, &buffer, UInt32(buffer.count))
        guard written > 0, let path = String(bytes: buffer[..<Int(written)], encoding: .utf8) else { return nil }
        return path.split(separator: "/").last.map(String.init)
    }
}
