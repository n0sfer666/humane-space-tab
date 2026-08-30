enum ForbiddenAPIRules {
    static let all: [ForbiddenSymbol] = networking + screenCapture + automation + interProcess + dynamicLoading

    private static let networking: [ForbiddenSymbol] = [
        "URLSession", "URLRequest", "NSURLConnection", "Network", "NWConnection", "NWListener",
        "NWBrowser", "CFSocket", "CFStream", "getaddrinfo",
    ].map { ForbiddenSymbol($0, reason: "the app has no network code") }

    private static let screenCapture: [ForbiddenSymbol] = [
        "ScreenCaptureKit", "SCStream", "SCShareableContent", "CGWindowListCreateImage",
        "CGDisplayCreateImage", "CGDisplayStream",
    ].map { ForbiddenSymbol($0, reason: "the app never captures screen content") }

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
            reason: "dynamic loading is allowed only in the SkyLight shim",
            allowedFiles: ["SkyLightShim.swift"]
        )
    }
}
