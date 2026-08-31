import AppKit
import SwitcherCore
import SystemPorts

@MainActor
final class IconSourceSpy: ApplicationIconSource {
    private(set) var prewarmed: [[ProcessIdentifier]] = []

    func icon(for process: ProcessIdentifier) -> NSImage? { nil }

    func prewarm(_ processes: [ProcessIdentifier]) { prewarmed.append(processes) }
}
