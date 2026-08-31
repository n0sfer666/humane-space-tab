public enum SwitcherEffect: Hashable, Sendable {
    case ignored
    case opened
    case moved
    case cancelled
    case committed(SwitcherTarget)
    case activationFailed(SwitcherTarget)
}
