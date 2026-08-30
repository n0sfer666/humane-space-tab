import Foundation

enum SourceTree {
    static var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    static var sourcesDirectory: URL {
        repositoryRoot.appendingPathComponent("Sources")
    }
}
