public enum WindowOwnership {
    public static let hopLimit = 4

    /// Attributes windows owned by helper processes to the application whose bundle contains them.
    /// - Parameters:
    ///   - regularApplications: every regular application by process, with its bundle path when known.
    ///   - executablePath: the executable path of any process, used to prove bundle containment.
    public static func resolve(
        windows: [WindowInfo],
        regularApplications: [ProcessIdentifier: String?],
        executablePath: (ProcessIdentifier) -> String?,
        parent: (ProcessIdentifier) -> ProcessIdentifier?
    ) -> [WindowInfo] {
        var resolved: [ProcessIdentifier: ProcessIdentifier?] = [:]
        return windows.compactMap { window in
            let owner = resolved.getOrPut(window.owner) {
                application(
                    owning: window.owner,
                    regularApplications: regularApplications,
                    executablePath: executablePath,
                    parent: parent
                )
            }
            return owner.map(window.owned(by:))
        }
    }

    private static func application(
        owning process: ProcessIdentifier,
        regularApplications: [ProcessIdentifier: String?],
        executablePath: (ProcessIdentifier) -> String?,
        parent: (ProcessIdentifier) -> ProcessIdentifier?
    ) -> ProcessIdentifier? {
        if regularApplications[process] != nil { return process }
        guard let path = executablePath(process) else { return nil }
        var current = process
        var visited: Set<ProcessIdentifier> = [process]
        for _ in 0..<hopLimit {
            guard let next = parent(current), !visited.contains(next) else { return nil }
            visited.insert(next)
            current = next
            guard let bundle = regularApplications[current] else { continue }
            guard let bundle, path.hasPrefix(bundle + "/") else { return nil }
            return current
        }
        return nil
    }
}

extension Dictionary {
    fileprivate mutating func getOrPut(_ key: Key, _ make: () -> Value) -> Value {
        if let existing = self[key] { return existing }
        let value = make()
        self[key] = value
        return value
    }
}
