public struct MRUOrder: Sendable, Equatable {
    private static let capacity = 64

    private var processes: [ProcessIdentifier]

    /// Seeds the order most recent first; duplicates keep their earliest position.
    public init(seed: [ProcessIdentifier] = []) {
        var seen: Set<ProcessIdentifier> = []
        processes = Array(seed.filter { seen.insert($0).inserted }.prefix(Self.capacity))
    }

    public mutating func record(_ process: ProcessIdentifier) {
        processes.removeAll { $0 == process }
        processes.insert(process, at: 0)
        processes.removeLast(max(0, processes.count - Self.capacity))
    }

    public func ordered(_ applications: [SwitchableApplication]) -> [SwitchableApplication] {
        var rank: [ProcessIdentifier: Int] = [:]
        for (position, process) in processes.enumerated() { rank[process] = position }
        return applications.enumerated()
            .sorted { left, right in
                let leftRank = rank[left.element.pid] ?? Int.max
                let rightRank = rank[right.element.pid] ?? Int.max
                return leftRank == rightRank ? left.offset < right.offset : leftRank < rightRank
            }
            .map(\.element)
    }
}
