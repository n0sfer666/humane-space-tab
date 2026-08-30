import Darwin
import SwitcherCore
import Testing

@testable import SystemAdapters

@Suite("Libproc process hierarchy")
struct LibprocProcessHierarchyTests {
    private let hierarchy = LibprocProcessHierarchy()

    @Test("the parent of this process is the one the system reports")
    func parentOfCurrentProcess() {
        let parent = hierarchy.parent(of: ProcessIdentifier(rawValue: getpid()))
        #expect(parent == ProcessIdentifier(rawValue: getppid()))
    }

    @Test("this process reports an absolute executable path")
    func executablePathOfCurrentProcess() {
        let path = hierarchy.executablePath(of: ProcessIdentifier(rawValue: getpid()))
        #expect(path?.hasPrefix("/") == true)
    }

    @Test("a process that does not exist has no executable path")
    func executablePathOfMissingProcess() {
        #expect(hierarchy.executablePath(of: ProcessIdentifier(rawValue: 999_999)) == nil)
    }

    @Test("a process that does not exist has no parent")
    func missingProcess() {
        #expect(hierarchy.parent(of: ProcessIdentifier(rawValue: 999_999)) == nil)
    }

    @Test("the launch daemon is its own root and reports no usable parent")
    func rootProcess() {
        #expect(hierarchy.parent(of: ProcessIdentifier(rawValue: 1)) == nil)
    }
}
