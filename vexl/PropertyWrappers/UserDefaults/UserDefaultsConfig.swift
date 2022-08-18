//
//  UserDefaultsConfig.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

enum UserDefaultKey: String {
    case hasSeenOnboarding
    case storedUser
    case storedSecurity
    case storedOfferKeys
    case selectedCurrency
    case lastOfferSyncDate
    case onboardingState
}

struct UserDefaultsConfig {
    @UserDefault(UserDefaultKey.hasSeenOnboarding.rawValue, defaultValue: false) static var hasSeenOnboarding: Bool

    static func removeAll() {
        UserDefaults.standard.dictionaryRepresentation().keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        UserDefaults.standard.synchronize()
    }

    static func removeAll(except keys: UserDefaultKey...) {
        let keyValues = keys.map { $0.rawValue }
        UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
            if !keyValues.contains(key) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
    }
}
