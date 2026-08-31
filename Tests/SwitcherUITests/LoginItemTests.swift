import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Login item")
struct LoginItemTests {
    @Test("turning it on registers the app and reports what the system now says")
    func registers() {
        let service = LoginItemServiceStub()
        let log = LogSpy()
        let item = LoginItem(service: service, log: log)
        item.set(true)
        #expect(service.registered == 1)
        #expect(item.status == .enabled)
        #expect(item.failure == nil)
        #expect(log.events.isEmpty)
    }

    @Test("a refused registration keeps the state the system reports and says why")
    func reportsFailure() {
        let service = LoginItemServiceStub()
        service.fails = true
        let log = LogSpy()
        let item = LoginItem(service: service, log: log)
        item.set(true)
        #expect(item.status == .notRegistered)
        #expect(item.failure?.isEmpty == false)
        #expect(log.events == [.loginItemChangeFailed])
    }

    @Test("a change that goes through clears the reason the last one failed")
    func clearsFailure() {
        let service = LoginItemServiceStub()
        service.fails = true
        let item = LoginItem(service: service, log: LogSpy())
        item.set(true)
        service.fails = false
        item.set(true)
        #expect(item.failure == nil)
    }

    @Test("turning it off unregisters the app")
    func unregisters() {
        let service = LoginItemServiceStub()
        service.status = .enabled
        let item = LoginItem(service: service, log: LogSpy())
        item.set(false)
        #expect(service.unregistered == 1)
        #expect(item.status == .notRegistered)
    }
}
