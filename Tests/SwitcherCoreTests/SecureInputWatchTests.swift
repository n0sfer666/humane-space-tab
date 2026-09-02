import SwitcherCore
import Testing

@Suite("Secure input watch")
struct SecureInputWatchTests {
    private static let ghostty = SecureInputHolder(process: ProcessIdentifier(rawValue: 1210), name: "Ghostty")
    private static let login = SecureInputHolder(process: ProcessIdentifier(rawValue: 609), name: "loginwindow")

    @Test("a hold shorter than the threshold is the sound of somebody typing a password")
    func aShortHoldIsNotReported() {
        var watch = SecureInputWatch()
        watch.observe(Self.ghostty, at: 0)
        watch.observe(Self.ghostty, at: 2.9)
        #expect(watch.settled == nil)
    }

    @Test("a hold that outlasts the threshold is reported with its holder")
    func aLongHoldIsReported() {
        var watch = SecureInputWatch()
        watch.observe(Self.ghostty, at: 0)
        watch.observe(Self.ghostty, at: 3)
        #expect(watch.settled == Self.ghostty)
    }

    @Test("a hold that ends is forgotten at once, without waiting for anything")
    func aReleasedHoldIsForgotten() {
        var watch = SecureInputWatch()
        watch.observe(Self.ghostty, at: 0)
        watch.observe(Self.ghostty, at: 4)
        watch.observe(nil, at: 4.1)
        #expect(watch.settled == nil)
    }

    @Test("a second holder starts the count again rather than inheriting the age of the first")
    func aNewHolderStartsOver() {
        var watch = SecureInputWatch()
        watch.observe(Self.ghostty, at: 0)
        watch.observe(Self.login, at: 2.9)
        #expect(watch.settled == nil)
        watch.observe(Self.login, at: 5.8)
        #expect(watch.settled == nil)
        watch.observe(Self.login, at: 6)
        #expect(watch.settled == Self.login)
    }

    @Test("a hold reported once stays reported for as long as it lasts")
    func aReportedHoldStays() {
        var watch = SecureInputWatch()
        watch.observe(Self.ghostty, at: 0)
        watch.observe(Self.ghostty, at: 3)
        watch.observe(Self.ghostty, at: 30)
        #expect(watch.settled == Self.ghostty)
    }

    @Test("a hold nobody can name is still a hold")
    func anUnnamedHolderIsReported() {
        let unnamed = SecureInputHolder(process: ProcessIdentifier(rawValue: 42), name: nil)
        var watch = SecureInputWatch()
        watch.observe(unnamed, at: 0)
        watch.observe(unnamed, at: 3)
        #expect(watch.settled == unnamed)
    }
}
