/// Who is holding secure input, while someone is. The name is the part a person can act on:
/// a bare number names nothing they can close. It stays optional because a process that
/// will not say what it is remains worth reporting.
public struct SecureInputHolder: Hashable, Sendable {
    public let process: ProcessIdentifier
    public let name: String?

    public init(process: ProcessIdentifier, name: String?) {
        self.process = process
        self.name = name
    }
}
