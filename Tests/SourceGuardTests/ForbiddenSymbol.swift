struct ForbiddenSymbol: Sendable {
    let symbol: String
    let reason: String
    let allowedFiles: Set<String>

    init(_ symbol: String, reason: String, allowedFiles: Set<String> = []) {
        self.symbol = symbol
        self.reason = reason
        self.allowedFiles = allowedFiles
    }
}
