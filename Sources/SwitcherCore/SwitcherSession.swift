public struct SwitcherSession: Equatable, Sendable {
    public let applications: [SwitchableApplication]
    public private(set) var selection: Int

    init?(applications: [SwitchableApplication], direction: SelectionDirection) {
        guard !applications.isEmpty else { return nil }
        self.applications = applications
        selection = 0
        step(direction)
    }

    public var selected: SwitchableApplication {
        applications[selection]
    }

    mutating func step(_ direction: SelectionDirection) {
        let count = applications.count
        selection = (selection + direction.offset + count) % count
    }
}

extension SelectionDirection {
    fileprivate var offset: Int {
        switch self {
        case .forward: 1
        case .backward: -1
        }
    }
}
