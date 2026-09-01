import SwitcherCore

/// The stand-in applications a sample is drawn with. They are numbered rather than named
/// after anything on the machine: the sample is about the shape of the ribbon, and a real
/// name would invite the reading that the ribbon is showing what is open right now.
enum PreviewEntries {
    static let counts = [1, 2, 3, 5, 10, 20, 50, 100]

    static func make(_ count: Int) -> [SwitcherEntry] {
        (0..<max(count, 0)).map { index in
            SwitcherEntry(
                application: SwitchableApplication(
                    pid: ProcessIdentifier(rawValue: Int32(index + 1)),
                    bundleIdentifier: nil,
                    name: "Application \(index + 1)",
                    isActive: false,
                    windows: []
                )
            )
        }
    }
}
