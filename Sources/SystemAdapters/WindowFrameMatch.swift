import CoreGraphics
import SwitcherCore

/// Pairs the window server's windows with an accessibility client's, which have no shared
/// identifier in public API. The frame is the only fact both report, so it is the key; when
/// two windows of one application share a frame to the pixel, their order in each list is
/// the tie-break, and a count that does not match drops the pair rather than guessing.
enum WindowFrameMatch {
    struct Key: Hashable {
        let left: Int
        let top: Int
        let width: Int
        let height: Int

        init(_ frame: CGRect) {
            left = Int(frame.origin.x.rounded())
            top = Int(frame.origin.y.rounded())
            width = Int(frame.width.rounded())
            height = Int(frame.height.rounded())
        }
    }

    static func pair<Element>(
        windows: [(id: WindowIdentifier, frame: CGRect)],
        elements: [(element: Element, frame: CGRect)]
    ) -> [WindowIdentifier: Element] {
        let grouped = Dictionary(grouping: elements) { Key($0.frame) }
        var paired: [WindowIdentifier: Element] = [:]
        for (key, windows) in Dictionary(grouping: windows, by: { Key($0.frame) }) {
            guard let candidates = grouped[key], candidates.count == windows.count else { continue }
            for (window, candidate) in zip(windows, candidates) {
                paired[window.id] = candidate.element
            }
        }
        return paired
    }
}
