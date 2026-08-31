/// What a session lists. It travels with the command that opens the session and stays on
/// the session, because the interpreter has to read the release of a held modifier against
/// the shortcut that opened it and not against the other one.
public enum SwitcherScope: Hashable, Sendable {
    case applications
    case frontWindows
}
