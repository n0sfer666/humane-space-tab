import Foundation

/// A run of the sample: four seconds, the selection moving on once a second. It keeps no
/// timer of its own — the sheet drives it — so what it does can be checked without waiting
/// four seconds for the answer.
struct RibbonPreviewRun: Equatable {
    static let steps = 4
    static let interval: TimeInterval = 1

    let count: Int
    private(set) var selection = 0
    private(set) var taken = 0

    init(count: Int) {
        self.count = max(count, 0)
    }

    var isRunning: Bool { count >= 1 && taken < Self.steps }

    mutating func step() {
        guard isRunning else { return }
        taken += 1
        selection = (selection + 1) % count
    }
}
