/// Which entries the ribbon shows around the selected one. Past ten entries the ribbon stops
/// growing and becomes a window onto a list that wraps: the selection keeps its place, the
/// icons move under it, and a step is always the same distance for the eye. Ten or fewer and
/// there is nothing to scroll — the ribbon shows them all, where they are.
public enum CarouselWindow {
    public static let before = 4
    public static let after = 5
    public static let span = before + 1 + after

    public static func indices(count: Int, selection: Int) -> [Int] {
        guard count > 0 else { return [] }
        guard count > span else { return Array(0..<count) }
        return (0..<span).map { step in
            let index = (selection - before + step) % count
            return index < 0 ? index + count : index
        }
    }

    /// Where in the window the selection is drawn: fixed once the list is long enough to wrap.
    public static func place(of selection: Int, count: Int) -> Int {
        count > span ? before : selection
    }
}
