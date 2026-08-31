/// Which entries the ribbon shows, and where. The selection keeps its place and the entries
/// turn under it, so a step is always the same distance for the eye. The list has no ends:
/// past the last application comes the first. A Space with fewer applications than the ribbon
/// holds turns the same way, only with a shorter ribbon — no application is ever shown twice.
public enum CarouselWindow {
    public static let before = 4
    public static let after = 5
    public static let span = before + 1 + after

    public static func indices(count: Int, selection: Int) -> [Int] {
        guard count > 0 else { return [] }
        let place = place(of: selection, count: count)
        return (0..<min(count, span)).map { step in
            let index = (selection - place + step) % count
            return index < 0 ? index + count : index
        }
    }

    /// Where in the ribbon the selection is drawn. Once the list is longer than the ribbon it
    /// is the fifth slot, four entries in; a shorter ribbon keeps the selection in its middle,
    /// which is the same slot as the list grows to fill it.
    public static func place(of selection: Int, count: Int) -> Int {
        count > span ? before : max(count - 1, 0) / 2
    }
}
