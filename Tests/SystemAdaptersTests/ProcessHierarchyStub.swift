import SwitcherCore
import SystemPorts

struct ProcessHierarchyStub: ProcessHierarchy {
    func parent(of process: ProcessIdentifier) -> ProcessIdentifier? {
        nil
    }

    func executablePath(of process: ProcessIdentifier) -> String? {
        nil
    }
}
