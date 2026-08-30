public enum InventorySummary {
    public static func text(for applications: [SwitchableApplication]) -> String {
        guard !applications.isEmpty else { return "No switchable applications." }
        return applications.map(line).joined(separator: "\n")
    }

    private static func line(for application: SwitchableApplication) -> String {
        guard !application.windows.isEmpty else { return "\(application.name) — no windows" }
        let total = application.windows.count
        let noun = total == 1 ? "window" : "windows"
        return "\(application.name) — \(total) \(noun): \(breakdown(of: application.windows))"
    }

    private static func breakdown(of windows: [ApplicationWindow]) -> String {
        let labels: [(WindowVisibility, String)] = [
            (.onScreen, "on screen"),
            (.minimised, "minimised"),
            (.hiddenApplication, "hidden"),
        ]
        return labels.compactMap { visibility, label in
            let count = windows.count { $0.visibility == visibility }
            return count == 0 ? nil : "\(count) \(label)"
        }
        .joined(separator: ", ")
    }
}
