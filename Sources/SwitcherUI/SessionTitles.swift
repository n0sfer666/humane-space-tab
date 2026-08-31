import SwitcherCore
import SystemPorts

/// Reading a window title is synchronous IPC into another process, so it never happens on
/// the tap's critical path: the ribbon opens with application names, and each application's
/// answer relabels its entries as it arrives. Answers to a session that has already ended
/// are dropped, and nothing here is kept once the gesture is over.
@MainActor
public final class SessionTitles {
    private let source: any WindowTitleSource
    private var generation = 0
    public private(set) var known: [SwitcherTarget: String] = [:]

    public init(source: any WindowTitleSource) {
        self.source = source
    }

    public func begin(_ entries: [SwitcherEntry], report: @escaping @MainActor ([SwitcherTarget: String]) -> Void) {
        end()
        let wanted = Self.windows(of: entries)
        guard !wanted.isEmpty else { return }
        let generation = generation
        Task { @MainActor [weak self] in
            for (process, windows) in wanted {
                await Task.yield()
                guard let self, generation == self.generation else { return }
                merge(source.titles(of: process, windows: windows), of: process)
                report(known)
            }
        }
    }

    public func end() {
        generation += 1
        known = [:]
    }

    private func merge(_ answers: [WindowIdentifier: String], of process: ProcessIdentifier) {
        for (window, title) in answers {
            known[SwitcherTarget(pid: process, window: window)] = title
        }
    }

    /// Grouped by application, in the ribbon's own order, so the entries the user is about
    /// to reach are labelled first.
    private static func windows(of entries: [SwitcherEntry]) -> [(ProcessIdentifier, [WindowIdentifier])] {
        var order: [ProcessIdentifier] = []
        var windows: [ProcessIdentifier: [WindowIdentifier]] = [:]
        for entry in entries {
            guard let window = entry.window else { continue }
            if windows[entry.application.pid] == nil { order.append(entry.application.pid) }
            windows[entry.application.pid, default: []].append(window.id)
        }
        return order.map { ($0, windows[$0] ?? []) }
    }
}
