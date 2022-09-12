//
//  RemoteConfigManager.swift
//  vexl
//
//  Created by Diego Espinoza on 24/08/22.
//

import Foundation
import FirebaseRemoteConfig

protocol RemoteConfigManagerType {
    func getBoolValue(for key: RemoteConfigManager.Key) -> Bool
    func getIntValue(for key: RemoteConfigManager.Key) -> Int
}

class RemoteConfigManager: RemoteConfigManagerType {

    enum Key: String {
        case isMarketplaceLocked = "marketplace_locked"
        case remainingConstacts = "remaining_contacts_to_unlock"
    }

    private static var remoteConfig = RemoteConfig.remoteConfig()

    // MARK: - Configure remote config

    static func setup() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.fetchAndActivate()
    }

    // MARK: - Methods for getting remote values

    func getBoolValue(for key: RemoteConfigManager.Key) -> Bool {
        #if STAGING
        if key == .isMarketplaceLocked {
            return false
        }
        #endif
        return RemoteConfigManager.remoteConfig.configValue(forKey: key.rawValue).boolValue
    }

    func getIntValue(for key: RemoteConfigManager.Key) -> Int {
        RemoteConfigManager.remoteConfig.configValue(forKey: key.rawValue).numberValue.intValue
    }
}
