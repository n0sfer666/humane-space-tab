import Testing

@Suite("Source guard")
struct SourceGuardTests {
    private let guardian = SourceGuard(rules: ForbiddenAPIRules.all)

    @Test("networking symbols are rejected")
    func rejectsNetworking() {
        let violations = guardian.scan(file: "Downloader.swift", contents: "let s = URLSession.shared")
        #expect(violations.map(\.symbol) == ["URLSession"])
    }

    @Test("Network framework import is rejected")
    func rejectsNetworkImport() {
        let violations = guardian.scan(file: "Peer.swift", contents: "import Network\nlet c = NWConnection()")
        #expect(Set(violations.map(\.symbol)) == ["Network", "NWConnection"])
    }

    @Test("screen capture symbols are rejected")
    func rejectsScreenCapture() {
        let violations = guardian.scan(file: "Preview.swift", contents: "CGWindowListCreateImage(rect)\nSCStream()")
        #expect(Set(violations.map(\.symbol)) == ["CGWindowListCreateImage", "SCStream"])
    }

    @Test("automation symbols are rejected")
    func rejectsAutomation() {
        let violations = guardian.scan(file: "Runner.swift", contents: "NSAppleScript(source: x)")
        #expect(violations.map(\.symbol) == ["NSAppleScript"])
    }

    @Test("subprocess and cross-process symbols are rejected")
    func rejectsSubprocess() {
        let contents = "let p = Process()\nNSXPCConnection()\nDistributedNotificationCenter.default()"
        let violations = guardian.scan(file: "Spawn.swift", contents: contents)
        #expect(Set(violations.map(\.symbol)) == ["Process", "NSXPCConnection", "DistributedNotificationCenter"])
    }

    @Test("reading a window title is rejected")
    func rejectsWindowTitles() {
        let violations = guardian.scan(file: "Windows.swift", contents: "entry[kCGWindowName as String]")
        #expect(violations.map(\.symbol) == ["kCGWindowName"])
    }

    @Test("a neighbouring window key is not mistaken for the title key")
    func windowNumberIsNotWindowName() {
        #expect(guardian.scan(file: "Windows.swift", contents: "entry[kCGWindowNumber as String]").isEmpty)
    }

    @Test("dlopen is allowed only in the SkyLight shim")
    func dlopenAllowlist() {
        let contents = "let handle = dlopen(path, RTLD_LAZY)"
        #expect(guardian.scan(file: "SkyLightShim.swift", contents: contents).isEmpty)
        #expect(guardian.scan(file: "Switcher.swift", contents: contents).map(\.symbol) == ["dlopen"])
    }

    @Test("a longer identifier containing a forbidden symbol is not a violation")
    func noSubstringFalsePositive() {
        let contents = "let processor = ProcessInfoCache()\nlet n = NetworkPortDescription()"
        #expect(guardian.scan(file: "Cache.swift", contents: contents).isEmpty)
    }

    @Test("a symbol inside a longer word on the right is not a violation")
    func noPrefixFalsePositive() {
        #expect(guardian.scan(file: "Timing.swift", contents: "let systemProcessing = 1").isEmpty)
    }

    @Test("violations report a one-based line number")
    func reportsLineNumber() {
        let contents = "let a = 1\n\nlet s = URLSession.shared"
        #expect(guardian.scan(file: "A.swift", contents: contents).first?.line == 3)
    }

    @Test("the shipped sources contain no forbidden API")
    func shippedSourcesAreClean() throws {
        let violations = try guardian.scanTree(at: SourceTree.sourcesDirectory)
        #expect(violations.isEmpty, "\(violations)")
    }
}
