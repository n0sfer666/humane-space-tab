import Foundation
import SystemPorts

public struct UserDefaultsSpaceLayerPreference: SpaceLayerPreference {
    private static let key = "PrivateSpaceLayerEnabled"

    public init() {}

    public var prefersPrivateLayer: Bool {
        UserDefaults.standard.bool(forKey: Self.key)
    }
}
