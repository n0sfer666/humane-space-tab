import SwitcherCore
import SystemPorts

@MainActor
struct WindowSourceStub: WindowSource {
    let all: [WindowInfo]
    let onScreen: [WindowInfo]

    func windows() -> [WindowInfo] {
        all
    }

    func onScreenWindows() -> [WindowInfo] {
        onScreen
    }
}
