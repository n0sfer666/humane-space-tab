import Foundation
import SystemPorts

public struct UserDefaultsSpaceLayerPreference: SpaceLayerPreference {
    nonisolated(unsafe) private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var prefersPrivateLayer: Bool {
        defaults.bool(forKey: PreferencesKey.privateSpaceLayer)
    }
}
