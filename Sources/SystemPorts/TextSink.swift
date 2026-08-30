@MainActor
public protocol TextSink: Sendable {
    func write(_ text: String)
}
