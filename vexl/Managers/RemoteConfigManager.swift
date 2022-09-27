//
//  RemoteConfigManager.swift
//  vexl
//
//  Created by Diego Espinoza on 24/08/22.
//

import Foundation
import FirebaseRemoteConfig
import Combine

protocol RemoteConfigManagerType {
    var fetchCompleted: AnyPublisher<Void, Never> { get }
    func setup()
    func getBoolValue(for key: RemoteConfigManager.Key) -> Bool
    func getIntValue(for key: RemoteConfigManager.Key) -> Int
}

class RemoteConfigManager: RemoteConfigManagerType {

    enum Key: String {
        case isMarketplaceLocked = "marketplace_locked"
        case remainingConstacts = "remaining_contacts_to_unlock"
        case forceUpdate = "force_update_screen_showed"
        case maintenance = "maintenance_screen_showed"
    }

    var fetchCompleted: AnyPublisher<Void, Never> {
        _fetchCompleted.eraseToAnyPublisher()
    }

    private var remoteConfig = RemoteConfig.remoteConfig()
    private var _fetchCompleted: PassthroughSubject<Void, Never> = .init()

    // MARK: - Configure remote config

    func setup() {
        let settings = RemoteConfigSettings()
        let remoteConfig = RemoteConfig.remoteConfig()
        #if APPSTORE
        settings.minimumFetchInterval = 3600
        #else
        settings.minimumFetchInterval = 0
        #endif
        remoteConfig.configSettings = settings
        remoteConfig.fetchAndActivate { [weak self] _, error in
            if error == nil { self?._fetchCompleted.send(()) }
        }
    }

    // MARK: - Methods for getting remote values

    func getBoolValue(for key: RemoteConfigManager.Key) -> Bool {
        #if STAGING
        if key == .isMarketplaceLocked {
            return false
        }
        #endif
        return remoteConfig.configValue(forKey: key.rawValue).boolValue
    }

    func getIntValue(for key: RemoteConfigManager.Key) -> Int {
        remoteConfig.configValue(forKey: key.rawValue).numberValue.intValue
    }
}
