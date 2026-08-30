/// Keeps the selection on screen when a Space holds more applications than the ribbon shows,
/// by the smallest move that does it: the ribbon stays put while the selection is inside the
/// window, so cycling through a crowded Space does not slide the icons under the eye.
public struct RibbonScroll: Equatable, Sendable {
    public private(set) var offset = 0

    public init() {}

    public mutating func reset() { offset = 0 }

    @discardableResult
    public mutating func settle(selection: Int, count: Int, visible: Int) -> Int {
        guard visible > 0, count > visible else {
            offset = 0
            return offset
        }
        let last = count - visible
        var next = min(offset, last)
        if selection < next { next = selection }
        if selection > next + visible - 1 { next = selection - visible + 1 }
        offset = min(max(next, 0), last)
        return offset
    }
}
