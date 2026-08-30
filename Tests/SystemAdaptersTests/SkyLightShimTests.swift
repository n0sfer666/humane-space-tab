import Foundation
import Testing

@testable import SystemAdapters

@Suite("SkyLight display parsing")
struct SkyLightShimTests {
    @Test("a display that reports its current space as a number is read")
    func numberShape() {
        #expect(SkyLightShim.currentSpace(on: ["Current Space": NSNumber(value: 3)]) == 3)
    }

    @Test("a display that reports its current space as a dictionary is read")
    func dictionaryShape() {
        let display: [String: Any] = ["Current Space": ["ManagedSpaceID": NSNumber(value: 4)]]
        #expect(SkyLightShim.currentSpace(on: display) == 4)
    }

    @Test("an unknown shape is refused instead of guessed")
    func unknownShape() {
        #expect(SkyLightShim.currentSpace(on: ["Current Space": "3"]) == nil)
        #expect(SkyLightShim.currentSpace(on: ["Current Space": ["Identifier": 3]]) == nil)
        #expect(SkyLightShim.currentSpace(on: [:]) == nil)
    }
}
