import AppKit
import SwitcherCore

@MainActor
public protocol ApplicationIconSource: AnyObject {
    /// The application's own icon, or nil when the process is gone.
    func icon(for process: ProcessIdentifier) -> NSImage?
    /// Loads icons ahead of a session so a keystroke never pays the first-load cost.
    func prewarm(_ processes: [ProcessIdentifier])
}
