//
//  KeychainService.swift
//  WiFi Monitor
//
//  Created by Adam Salih on 19.09.2021.
//

import Foundation
import Security

/// Quick generic keychain service implementation for key value keychain storing. This implementattion stores values as generic passwords and uses account attribute as a key.
struct KeychainService<EnumType: RawRepresentable> where EnumType.RawValue == String {
    let domain: String
    
    init(domain: String = Bundle.main.bundleIdentifier!) {
        self.domain = domain
    }
    
    private func query(for key: EnumType) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: domain,
            kSecAttrAccount as String: key.rawValue
        ]
    }
    
    func set(key: EnumType, value: String?) {
        delete(key: key)
        if let valueData = value?.data(using: .utf8) {
            var query = query(for: key)
            query[kSecValueData as String] = valueData
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    func get(key: EnumType) -> String? {
        var query = query(for: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        var result: AnyObject?
        let _ = withUnsafeMutablePointer(to: &result) { pointer in
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(pointer))
        }
        guard let dict = result as? [String: Any],
              let data = dict[kSecValueData as String] as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
        
    }
    
    private func delete(key: EnumType) {
        var query = query(for: key)
        query[kSecReturnData as String] = kCFBooleanFalse
        SecItemDelete(query as CFDictionary)
    }
}
