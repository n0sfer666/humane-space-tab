import AppKit
import SystemAdapters

let application = NSApplication.shared
let delegate = AppDelegate(log: OSLogSink())
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
