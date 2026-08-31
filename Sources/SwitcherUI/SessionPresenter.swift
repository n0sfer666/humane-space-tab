import Foundation
import SwitcherCore
import SystemPorts

/// Everything the ribbon needs doing when a session changes, in one place: the icons of a
/// newly listed application are loaded, its window titles are asked for, and the panel is
/// rendered with whatever titles have arrived so far.
@MainActor
public final class SessionPresenter {
    private let overlay: OverlayController
    private let icons: any ApplicationIconSource
    private let titles: SessionTitles
    private var current: SwitcherSession?

    /// Preferences (S08) change the reveal delay between sessions; the panel is behind the
    /// presenter now, so the setting reaches it through here.
    public var delay: TimeInterval {
        get { overlay.delay }
        set { overlay.delay = newValue }
    }

    public init(overlay: OverlayController, icons: any ApplicationIconSource, titles: SessionTitles) {
        self.overlay = overlay
        self.icons = icons
        self.titles = titles
    }

    public func show(_ session: SwitcherSession?, opened: Bool) {
        current = session
        if opened, let session {
            prewarm(session.entries)
            titles.begin(session.entries) { [weak self] known in self?.relabel(known) }
        }
        if session == nil { titles.end() }
        overlay.render(session.map { OverlayModel(session: $0, titles: titles.known) })
    }

    private func relabel(_ known: [SwitcherTarget: String]) {
        guard let current else { return }
        overlay.render(OverlayModel(session: current, titles: known))
    }

    /// An application launched after this one pays its first icon load here, in the gap
    /// between the gesture opening and the ribbon appearing, never inside the tap callback.
    private func prewarm(_ entries: [SwitcherEntry]) {
        let processes = entries.map(\.application.pid)
        Task { @MainActor [icons] in icons.prewarm(processes) }
    }
}
