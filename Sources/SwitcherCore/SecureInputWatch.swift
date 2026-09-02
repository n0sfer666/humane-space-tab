/// Secure input is ordinary: every password field turns it on for as long as it holds the
/// focus, and while it does no key press reaches any tap. Reporting that would cry wolf at
/// every login, so the watch reports only a hold that outlasts someone typing a password —
/// which is the shape the stuck holds take, and they are the ones a person can do
/// something about.
public struct SecureInputWatch: Equatable, Sendable {
    public static let threshold = 3.0

    public private(set) var settled: SecureInputHolder?
    private var held: SecureInputHolder?
    private var since = 0.0

    public init() {}

    /// A different holder starts the count again: two password fields in a row are two
    /// ordinary holds, not one long one.
    public mutating func observe(_ holder: SecureInputHolder?, at moment: Double) {
        guard let holder else {
            held = nil
            settled = nil
            return
        }
        guard held == holder else {
            held = holder
            since = moment
            settled = nil
            return
        }
        settled = moment - since >= Self.threshold ? holder : nil
    }
}
