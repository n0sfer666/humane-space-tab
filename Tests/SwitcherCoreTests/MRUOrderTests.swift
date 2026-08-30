import Testing

@testable import SwitcherCore

@Suite("MRU order")
struct MRUOrderTests {
    private func pid(_ raw: Int32) -> ProcessIdentifier { ProcessIdentifier(rawValue: raw) }

    private func application(_ raw: Int32) -> SwitchableApplication {
        SwitchableApplication(
            pid: pid(raw),
            bundleIdentifier: "test.\(raw)",
            name: "App \(raw)",
            isActive: false,
            windows: []
        )
    }

    private func order(_ mru: MRUOrder, _ applications: [Int32]) -> [Int32] {
        mru.ordered(applications.map(application)).map(\.pid.rawValue)
    }

    @Test("an empty order leaves the applications as they are")
    func emptyOrderKeepsInput() {
        #expect(order(MRUOrder(), [1, 2, 3]) == [1, 2, 3])
    }

    @Test("applications follow the seeded order")
    func seededOrderWins() {
        #expect(order(MRUOrder(seed: [3, 1, 2].map(pid)), [1, 2, 3]) == [3, 1, 2])
    }

    @Test("applications the order does not know follow the known ones")
    func unknownApplicationsGoLast() {
        #expect(order(MRUOrder(seed: [3].map(pid)), [1, 2, 3]) == [3, 1, 2])
    }

    @Test("recording an activation moves that application to the front")
    func activationMovesToFront() {
        var mru = MRUOrder(seed: [1, 2, 3].map(pid))
        mru.record(pid(3))
        #expect(order(mru, [1, 2, 3]) == [3, 1, 2])
    }

    @Test("recording the same application twice keeps one entry")
    func activationDoesNotDuplicate() {
        var mru = MRUOrder(seed: [1, 2].map(pid))
        mru.record(pid(2))
        mru.record(pid(2))
        #expect(order(mru, [1, 2]) == [2, 1])
    }

    @Test("recording an application the order never saw puts it first")
    func unknownActivationIsPrepended() {
        var mru = MRUOrder(seed: [1, 2].map(pid))
        mru.record(pid(9))
        #expect(order(mru, [1, 2, 9]) == [9, 1, 2])
    }

    @Test("a repeated process is seeded once, at its earliest position")
    func seedDropsDuplicates() {
        let mru = MRUOrder(seed: [2, 1, 2].map(pid))
        #expect(order(mru, [1, 2]) == [2, 1])
    }

    @Test("the order forgets the least recent process once it is full")
    func orderIsBounded() {
        var mru = MRUOrder(seed: (1...64).map { pid(Int32($0)) })
        mru.record(pid(100))
        #expect(order(mru, [200, 64]) == [200, 64])
    }
}
