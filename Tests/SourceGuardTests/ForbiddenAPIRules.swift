enum ForbiddenAPIRules {
    static let all: [ForbiddenSymbol] =
        networking + screenCapture + automation + interProcess + dynamicLoading + windowContent

    private static let networking: [ForbiddenSymbol] = [
        "URLSession", "URLRequest", "NSURLConnection", "Network", "NWConnection", "NWListener",
        "NWBrowser", "CFSocket", "CFStream", "getaddrinfo",
    ].map { ForbiddenSymbol($0, reason: "the app has no network code") }

    private static let screenCapture: [ForbiddenSymbol] = [
        "ScreenCaptureKit", "SCStream", "SCShareableContent", "CGWindowListCreateImage",
        "CGDisplayCreateImage", "CGDisplayStream",
    ].map { ForbiddenSymbol($0, reason: "the app never captures screen content") }

    private static let windowContent: [ForbiddenSymbol] = [
        ForbiddenSymbol(
            "kCGWindowName",
            reason: "a title from the window server would require Screen Recording"
        ),
        ForbiddenSymbol(
            "kAXTitleAttribute",
            reason: "only S16's window mode reads a title, and only over accessibility",
            allowedFiles: ["AXWindowTitles.swift"]
        ),
    ]

    private static let automation: [ForbiddenSymbol] = [
        "NSAppleScript", "NSAppleEventDescriptor", "OSAScript", "AEDesc",
    ].map { ForbiddenSymbol($0, reason: "the app never drives other applications") }

    private static let interProcess: [ForbiddenSymbol] = [
        "NSXPCConnection", "NSXPCListener", "CFMessagePort", "DistributedNotificationCenter",
        "CFNotificationCenterGetDistributedCenter", "Process", "NSTask", "posix_spawn", "execve",
    ].map { ForbiddenSymbol($0, reason: "the app has no incoming channel and spawns no processes") }

    private static let dynamicLoading: [ForbiddenSymbol] = [
        "dlopen", "dlsym",
    ].map {
        ForbiddenSymbol(
            $0,
            reason: "dynamic loading is allowed only in the two private-symbol shims",
            allowedFiles: ["SkyLightShim.swift", "AXWindowIDShim.swift"]
        )
    }
}
