import SwitcherCore

/// What the pointer did to the ribbon, in the ribbon's own terms: the view knows tiles, the
/// session knows entries, and this is the only vocabulary between them.
public enum RibbonGesture: Equatable, Sendable {
    case select(Int)
    case commit(Int)
    case step(SelectionDirection)
}
