//
//  UserDefault.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

extension UserDefaults {

    func set<Element: Codable>(value: Element, forKey key: UserDefaultKey) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.setValue(data, forKey: key.rawValue)
    }

    func codable<Element: Codable>(forKey key: UserDefaultKey) -> Element? {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
        let element = try? JSONDecoder().decode(Element.self, from: data)
        return element
    }
}
