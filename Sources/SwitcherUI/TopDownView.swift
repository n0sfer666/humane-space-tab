import AppKit

/// A view whose origin is its top left. AppKit measures from the bottom up, which puts a
/// scroll view at the end of its content when it opens; a document laid out top down opens
/// where a person expects to start reading.
@MainActor
final class TopDownView: NSView {
    override var isFlipped: Bool { true }
}
