import ApplicationServices
import CoreGraphics
import Darwin
import SwitcherCore

/// The accessibility API names no window server id, and the window server names no
/// accessibility element: `_AXUIElementGetWindow` is the only bridge between them. It is
/// private, so it is reached the way S03 reaches SkyLight — resolved once by name, and its
/// absence degrades the feature instead of breaking the app.
struct AXWindowIDShim {
    private typealias GetWindow = @convention(c) (AXUIElement, UnsafeMutablePointer<CGWindowID>) -> AXError

    private static let framework =
        "/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices"

    private let getWindow: GetWindow

    init?() {
        guard let handle = dlopen(Self.framework, RTLD_LAZY) else { return nil }
        guard let symbol = dlsym(handle, "_AXUIElementGetWindow") else {
            dlclose(handle)
            return nil
        }
        getWindow = unsafeBitCast(symbol, to: GetWindow.self)
    }

    /// The id the window server knows an element by, or `nil` for an element that is not one
    /// of its windows — Finder's desktop answers that way, and it is not a window to switch to.
    func identifier(of element: AXUIElement) -> WindowIdentifier? {
        var identifier: CGWindowID = 0
        guard getWindow(element, &identifier) == .success, identifier != 0 else { return nil }
        return WindowIdentifier(rawValue: identifier)
    }
}
