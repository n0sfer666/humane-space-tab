import AppKit
import SwitcherCore
import SystemPorts

/// The two recorder rows of the settings window: one for the application ribbon, one for
/// the front application's windows (S12). They share a recorder source, so a row starting
/// ends the other — two fields both saying "Type a shortcut…" would leave the user typing
/// into whichever of them started last.
@MainActor
final class ShortcutRows {
    private(set) var applications: Shortcut
    private(set) var windows: Shortcut
    private var rows: [ShortcutRecorderView] = []

    init(
        preferences: Preferences,
        formatter: ShortcutFormatter,
        recording: any ShortcutRecorderSource,
        requestGrant: @escaping @MainActor () -> Void,
        onChange: @escaping @MainActor () -> Void
    ) {
        applications = preferences.shortcut
        windows = preferences.windowShortcut
        rows = [
            ShortcutRecorderView(
                shortcut: applications,
                standard: .commandTab,
                formatter: formatter,
                source: recording,
                requestGrant: requestGrant,
                taken: { [weak self] in self?.windows },
                willRecord: { [weak self] in self?.endRecording(except: 0) },
                onChange: { [weak self] in
                    self?.applications = $0
                    onChange()
                }
            ),
            ShortcutRecorderView(
                shortcut: windows,
                standard: .commandGrave,
                formatter: formatter,
                source: recording,
                requestGrant: requestGrant,
                taken: { [weak self] in self?.applications },
                willRecord: { [weak self] in self?.endRecording(except: 1) },
                onChange: { [weak self] in
                    self?.windows = $0
                    onChange()
                }
            ),
        ]
    }

    var applicationsView: NSView { rows[0] }
    var windowsView: NSView { rows[1] }

    private func endRecording(except index: Int) {
        for (position, row) in rows.enumerated() where position != index {
            row.endRecording()
        }
    }
}
