import Foundation
import SystemPorts

public struct UserDefaultsWindowSwitching: WindowSwitchingPreference {
    nonisolated(unsafe) private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var switchesWindows: Bool {
        defaults.bool(forKey: PreferencesKey.windowSwitching)
    }
}
