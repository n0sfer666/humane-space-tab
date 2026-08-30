/// Something that can put the switcher's tap out of the way and bring it back. The tap has
/// exactly one owner, so anything that needs the keyboard to itself asks that owner rather
/// than stopping the engine behind its back.
@MainActor
public protocol TapSuspending: AnyObject {
    func suspend()
    func resume()
}
