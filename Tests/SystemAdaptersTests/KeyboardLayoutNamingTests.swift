import Foundation
import SwitcherCore
import Testing

@testable import SystemAdapters

@Suite("Keyboard layout naming")
@MainActor
struct KeyboardLayoutNamingTests {
    @Test("an ordinary key is named by whatever the current layout prints on it")
    func namesOrdinaryKey() {
        let name = KeyboardLayoutNaming().name(for: .letterQ)
        #expect(name != nil)
        #expect(name?.isEmpty == false)
        #expect(name?.rangeOfCharacter(from: .controlCharacters) == nil)
        #expect(name == name?.uppercased())
    }

    @Test("two different positions are named differently")
    func distinguishesKeys() {
        let naming = KeyboardLayoutNaming()
        #expect(naming.name(for: .letterQ) != naming.name(for: .letterW))
    }
}
