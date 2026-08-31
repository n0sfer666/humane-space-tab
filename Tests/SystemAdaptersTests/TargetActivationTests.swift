import SwitcherCore
import SystemPorts
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Target activation")
struct TargetActivationTests {
    private final class ActivatorSpy: ApplicationActivator {
        var activated: [ProcessIdentifier] = []
        var succeeds = true

        func activate(_ process: ProcessIdentifier) -> Bool {
            activated.append(process)
            return succeeds
        }
    }

    private final class RaiserSpy: WindowRaiser {
        var raised: [(WindowIdentifier, ProcessIdentifier)] = []
        var succeeds = true

        func raise(_ window: WindowIdentifier, of process: ProcessIdentifier) -> Bool {
            raised.append((window, process))
            return succeeds
        }
    }

    private let process = ProcessIdentifier(rawValue: 7)
    private let window = WindowIdentifier(rawValue: 11)

    @Test("a window is raised inside its application, and the application activated")
    func raisesThenActivates() {
        let activator = ActivatorSpy()
        let raiser = RaiserSpy()
        let activation = TargetActivation(activator: activator, raiser: raiser)
        #expect(activation.activate(SwitcherTarget(pid: process, window: window)))
        #expect(raiser.raised.map(\.0) == [window])
        #expect(activator.activated == [process])
    }

    @Test("an application entry is activated without touching accessibility")
    func activatesApplicationAlone() {
        let activator = ActivatorSpy()
        let raiser = RaiserSpy()
        let activation = TargetActivation(activator: activator, raiser: raiser)
        #expect(activation.activate(SwitcherTarget(pid: process)))
        #expect(raiser.raised.isEmpty)
        #expect(activator.activated == [process])
    }

    @Test("a window the raise cannot find still activates its application")
    func survivesAFailedRaise() {
        let activator = ActivatorSpy()
        let raiser = RaiserSpy()
        raiser.succeeds = false
        let activation = TargetActivation(activator: activator, raiser: raiser)
        #expect(activation.activate(SwitcherTarget(pid: process, window: window)))
    }

    @Test("an application that is gone is reported as a failure")
    func reportsAFailedActivation() {
        let activator = ActivatorSpy()
        activator.succeeds = false
        let activation = TargetActivation(activator: activator, raiser: RaiserSpy())
        #expect(activation.activate(SwitcherTarget(pid: process, window: window)) == false)
    }
}
