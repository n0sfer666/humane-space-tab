import AppKit
import SwitcherCore
import SystemPorts

/// Icons for a sample. The applications the user has open are the ones they will recognise,
/// so the sample borrows their icons in turn and falls back to the generic application icon
/// where there are fewer of them than slots. Nothing is read but the icons themselves.
@MainActor
final class PreviewIcons: ApplicationIconSource {
    private let borrowed: [NSImage]
    private let generic = NSWorkspace.shared.icon(for: .applicationBundle)

    init() {
        borrowed = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap(\.icon)
    }

    func icon(for process: ProcessIdentifier) -> NSImage? {
        guard !borrowed.isEmpty else { return generic }
        return borrowed[Int(process.rawValue) % borrowed.count]
    }

    func prewarm(_ processes: [ProcessIdentifier]) {}
}
