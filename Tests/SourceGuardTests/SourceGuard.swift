import Foundation

struct SourceGuard: Sendable {
    let rules: [ForbiddenSymbol]

    func scan(file: String, contents: String) -> [Violation] {
        let applicable = rules.filter { !$0.allowedFiles.contains(file) }
        var violations: [Violation] = []
        for (index, line) in contents.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
            for rule in applicable where Self.containsIdentifier(rule.symbol, in: line) {
                violations.append(
                    Violation(file: file, symbol: rule.symbol, line: index + 1, reason: rule.reason)
                )
            }
        }
        return violations
    }

    func scanTree(at directory: URL) throws -> [Violation] {
        try swiftFiles(in: directory).flatMap { url in
            scan(file: url.lastPathComponent, contents: try String(contentsOf: url, encoding: .utf8))
        }
    }

    private func swiftFiles(in directory: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            throw SourceGuardError.unreadableDirectory(directory)
        }
        return
            enumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }
            .sorted { $0.path < $1.path }
    }

    private static func containsIdentifier(_ symbol: String, in line: Substring) -> Bool {
        var searchStart = line.startIndex
        while let range = line.range(of: symbol, range: searchStart..<line.endIndex) {
            let leftIsFree =
                range.lowerBound == line.startIndex
                || !isIdentifierCharacter(line[line.index(before: range.lowerBound)])
            let rightIsFree =
                range.upperBound == line.endIndex
                || !isIdentifierCharacter(line[range.upperBound])
            if leftIsFree && rightIsFree { return true }
            searchStart = range.upperBound
        }
        return false
    }

    private static func isIdentifierCharacter(_ character: Character) -> Bool {
        character.isLetter || character.isNumber || character == "_"
    }
}

enum SourceGuardError: Error {
    case unreadableDirectory(URL)
}
