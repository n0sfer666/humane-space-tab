import CoreGraphics

final class HotkeyEventTap {
    private let port: CFMachPort
    private let source: CFRunLoopSource

    init?(port: CFMachPort?) {
        guard let port, let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0) else {
            if let port { CFMachPortInvalidate(port) }
            return nil
        }
        self.port = port
        self.source = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        setEnabled(true)
    }

    func setEnabled(_ enabled: Bool) {
        CGEvent.tapEnable(tap: port, enable: enabled)
    }

    deinit {
        CGEvent.tapEnable(tap: port, enable: false)
        CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        CFMachPortInvalidate(port)
    }
}
