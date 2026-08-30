struct Violation: Equatable, Sendable, CustomStringConvertible {
    let file: String
    let symbol: String
    let line: Int
    let reason: String

    var description: String { "\(file):\(line): \(symbol) — \(reason)" }
}
