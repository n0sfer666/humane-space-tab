import SwitcherCore
import SystemPorts

@MainActor
struct KeyNamingStub: KeyNaming {
    let names: [KeyCode: String]

    func name(for key: KeyCode) -> String? { names[key] }
}
