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
}

class RemoteConfigManager: RemoteConfigManagerType {

    enum Key: String {
        case isMarketplaceLocked = "marketplace_locked"
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
        RemoteConfigManager.remoteConfig.configValue(forKey: key.rawValue).boolValue
    }
}
