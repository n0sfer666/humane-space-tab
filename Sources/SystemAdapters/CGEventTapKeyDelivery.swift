import CoreGraphics
import SystemPorts

/// Asks the window server what this process's taps actually got. The mask a tap was created
/// with and the mask it ends up with are different facts, and only the second one decides
/// whether a key press ever arrives.
public final class CGEventTapKeyDelivery: KeyEventDelivery {
    private static let keyBits =
        CGEventMask(1 << CGEventType.keyDown.rawValue) | CGEventMask(1 << CGEventType.keyUp.rawValue)

    private let pid: pid_t

    public init(pid: pid_t = getpid()) {
        self.pid = pid
    }

    public var deliversKeyEvents: Bool {
        Self.taps(of: pid).contains { Self.carriesKeys($0.eventsOfInterest) }
    }

    /// A tap with no key bits left is deaf; a process with no tap at all is a different
    /// problem, reported by the permission state as a missing tap rather than as silence.
    public static func carriesKeys(_ mask: CGEventMask) -> Bool {
        mask & keyBits == keyBits
    }

    private static func taps(of pid: pid_t) -> [CGEventTapInformation] {
        var count: UInt32 = 0
        guard CGGetEventTapList(0, nil, &count) == .success, count > 0 else { return [] }
        var taps = [CGEventTapInformation](repeating: CGEventTapInformation(), count: Int(count))
        guard CGGetEventTapList(count, &taps, &count) == .success else { return [] }
        return taps.prefix(Int(count)).filter { $0.tappingProcess == pid }
    }
}
