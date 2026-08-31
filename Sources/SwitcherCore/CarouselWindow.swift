/// Which entries the ribbon shows, and where. From five applications on, the ribbon is a
/// carousel: the selection keeps its slot and the entries turn under it, so a step is always
/// the same distance for the eye and the list has no ends — past the last application comes
/// the first. Below five there is too little to turn, and the ribbon is the plain row it
/// looks like: every icon keeps its place and only the selection moves.
public enum CarouselWindow {
    public static let before = 4
    public static let after = 5
    public static let span = before + 1 + after
    /// The shortest list that turns.
    public static let turning = 5

    public static func indices(count: Int, selection: Int) -> [Int] {
        guard count > 0 else { return [] }
        guard count >= turning else { return Array(0..<count) }
        let place = place(of: selection, count: count)
        return (0..<min(count, span)).map { step in
            let index = (selection - place + step) % count
            return index < 0 ? index + count : index
        }
    }

    /// Where in the ribbon the selection is drawn. A turning ribbon fills the room before the
    /// selection first, one entry at a time, and stops at four — the fifth slot, where the
    /// selection stays for every longer list.
    public static func place(of selection: Int, count: Int) -> Int {
        count < turning ? selection : min(count - before, before)
    }
}
