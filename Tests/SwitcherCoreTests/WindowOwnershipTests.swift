import Testing

@testable import SwitcherCore

@Suite("Window ownership")
struct WindowOwnershipTests {
    private func window(_ id: UInt32, owner: Int32) -> WindowInfo {
        WindowInfo(
            id: WindowIdentifier(rawValue: id),
            owner: ProcessIdentifier(rawValue: owner),
            layer: 0,
            alpha: 1,
            isOnScreen: true
        )
    }

    private func resolve(
        _ windows: [WindowInfo],
        regular: [Int32: String?] = [2: "/Applications/Steam.app"],
        paths: [Int32: String] = [:],
        parents: [Int32: Int32]
    ) -> [WindowInfo] {
        WindowOwnership.resolve(
            windows: windows,
            regularApplications: .init(
                uniqueKeysWithValues: regular.map { (ProcessIdentifier(rawValue: $0.key), $0.value) }
            ),
            executablePath: { paths[$0.rawValue] },
            parent: { parents[$0.rawValue].map { ProcessIdentifier(rawValue: $0) } }
        )
    }

    private let helperPath = "/Applications/Steam.app/Contents/MacOS/Helper"

    @Test("a window owned by a regular application is left alone")
    func regularOwnerUnchanged() {
        #expect(resolve([window(10, owner: 2)], parents: [:]).map(\.owner.rawValue) == [2])
    }

    @Test("a window owned by a helper inside the bundle is attributed to the application")
    func helperInsideBundle() {
        let result = resolve([window(10, owner: 5)], paths: [5: helperPath], parents: [5: 2])
        #expect(result.map(\.owner.rawValue) == [2])
    }

    @Test("a helper chain inside the bundle is walked until the application is found")
    func walksChainInsideBundle() {
        let result = resolve([window(10, owner: 7)], paths: [7: helperPath], parents: [7: 6, 6: 5, 5: 2])
        #expect(result.map(\.owner.rawValue) == [2])
    }

    @Test("a chain of exactly the hop limit still resolves")
    func chainAtHopLimit() {
        let parents: [Int32: Int32] = [9: 8, 8: 7, 7: 6, 6: 2]
        let result = resolve([window(10, owner: 9)], paths: [9: helperPath], parents: parents)
        #expect(result.map(\.owner.rawValue) == [2])
    }

    @Test("a chain longer than the hop limit discards the window")
    func chainTooLong() {
        let parents: [Int32: Int32] = [9: 8, 8: 7, 7: 6, 6: 5, 5: 2]
        #expect(resolve([window(10, owner: 9)], paths: [9: helperPath], parents: parents).isEmpty)
    }

    @Test("a process launched by an application it does not belong to is discarded")
    func launcherIsNotAnOwner() {
        let result = resolve(
            [window(10, owner: 5)],
            regular: [2: "/System/Applications/Utilities/Terminal.app"],
            paths: [5: "/Users/someone/build/tool"],
            parents: [5: 2]
        )
        #expect(result.isEmpty)
    }

    @Test("a bundle path is not matched by a longer sibling path")
    func siblingBundleIsNotAPrefix() {
        let result = resolve(
            [window(10, owner: 5)],
            paths: [5: "/Applications/Steam.app.old/Contents/MacOS/Helper"],
            parents: [5: 2]
        )
        #expect(result.isEmpty)
    }

    @Test("an application whose bundle path is unknown adopts no helper")
    func applicationWithoutBundlePath() {
        let result = resolve([window(10, owner: 5)], regular: [2: nil], paths: [5: helperPath], parents: [5: 2])
        #expect(result.isEmpty)
    }

    @Test("a helper whose executable path is unknown is discarded")
    func helperWithoutExecutablePath() {
        #expect(resolve([window(10, owner: 5)], parents: [5: 2]).isEmpty)
    }

    @Test("a chain that reaches no regular application discards the window")
    func chainWithoutRegularAncestor() {
        #expect(resolve([window(10, owner: 5)], paths: [5: helperPath], parents: [5: 4]).isEmpty)
    }

    @Test("a process that is its own parent does not loop forever")
    func selfParentTerminates() {
        #expect(resolve([window(10, owner: 5)], paths: [5: helperPath], parents: [5: 5]).isEmpty)
    }

    @Test("a cycle in the process tree does not loop forever")
    func cycleTerminates() {
        #expect(resolve([window(10, owner: 5)], paths: [5: helperPath], parents: [5: 6, 6: 5]).isEmpty)
    }

    @Test("no windows resolve to no windows")
    func noWindows() {
        #expect(resolve([], parents: [:]).isEmpty)
    }

    @Test("without a single regular application every window is discarded")
    func noRegularApplications() {
        #expect(resolve([window(10, owner: 2)], regular: [:], parents: [:]).isEmpty)
    }

    @Test("resolution keeps the window identity and order")
    func keepsIdentityAndOrder() {
        let result = resolve(
            [window(10, owner: 2), window(11, owner: 5), window(12, owner: 2)],
            paths: [5: helperPath],
            parents: [5: 2]
        )
        #expect(result.map(\.id.rawValue) == [10, 11, 12])
        #expect(result.allSatisfy { $0.owner.rawValue == 2 })
    }
}
