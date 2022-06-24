//
//  Codable+.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

extension KeyedDecodingContainer {

    func decode<D: Decodable>(forKey key: K) throws -> D {
        return try decode(D.self, forKey: key)
    }

    func decodeIfPresent<D: Decodable>(forKey key: K) throws -> D? {
        return try decodeIfPresent(D.self, forKey: key)
    }
}

enum CodingError: Error {
    case runtimeError(String)
}

public extension Decodable {
    /**
     Create an instance of this type from a json string

     - parameter json: The json string
     - parameter keyPath: for if you want something else than the root object
     */
    init(json: String, keyPath: String? = nil) throws {
        guard let data = json.data(using: .utf8) else { throw CodingError.runtimeError(R.string.generic.errorParseString()) }
        try self.init(data: data, keyPath: keyPath)
    }

    /**
     Create an instance of this type from a json dictionary

     - parameter json: The json dictionary
     - parameter keyPath: for if you want something else than the root object
     */
    init(json: [String: Any], keyPath: String? = nil) throws {
        let data = try JSONSerialization.data(withJSONObject: json)
        self = try Constants.jsonDecoder.decode(Self.self, from: data)
    }

    /**
     Create an instance of this type from a json data

     - parameter data: The json data
     - parameter keyPath: for if you want something else than the root object
     */
    init(data: Data, keyPath: String? = nil) throws {
        let decoder = Constants.jsonDecoder

        if let keyPath = keyPath {
            let topLevel = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            guard let nestedJson = (topLevel as AnyObject).value(forKeyPath: keyPath) else { throw CodingError.runtimeError(R.string.generic.errorDecodeObject()) }
            let nestedData = try JSONSerialization.data(withJSONObject: nestedJson)
            self = try decoder.decode(Self.self, from: nestedData)
            return
        }
        self = try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? Constants.jsonEncoder.encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

// MARK: - Any array Codable

struct JSONCodingKeys: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {

    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {

    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {

        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}
