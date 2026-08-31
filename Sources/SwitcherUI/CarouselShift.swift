/// How far the ribbon travelled between two windows, in slots. The entries themselves say it:
/// a window whose tail is the next window's head has moved on by one, and that is the only
/// move worth animating — a jump of several, or a ribbon that never moved, is drawn where it
/// lands.
public enum CarouselShift {
    public static func between(_ previous: [Int], _ current: [Int]) -> Int {
        guard previous.count == current.count, previous.count > 1 else { return 0 }
        if previous.dropFirst().elementsEqual(current.dropLast()) { return 1 }
        if current.dropFirst().elementsEqual(previous.dropLast()) { return -1 }
        return 0
    }
}
