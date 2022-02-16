//
//  Localization.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import Rswift

typealias LocalizationVariables = [String: String]

func tr(_ key: String, variables: LocalizationVariables = [:]) -> String? {
    return translateAll(key: key, variables: variables)
}

func tr(_ key: String, variables: LocalizationVariables = [:]) -> String {
    return translateAll(key: key, variables: variables) ?? key
}

func tr(_ key: String?, variables: LocalizationVariables = [:]) -> String? {
    return key.flatMap { translateAll(key: $0, variables: variables) }
}

func tr(_ resource: StringResource, variables: LocalizationVariables = [:]) -> String {
    return tr(resource.key, variables: variables)
}

// MARK: Core functions

/**
 Core function that finds localization key in some bundle, if not returns nil.

 Something pretty similar to NSLocalizedString
 */
private func translate(key: String, bundle: Bundle = Bundle.main) -> String? {
    let defaultValue = "THIS_IS_DEFINITELY_NOT_USED_IN_LOCALIZABLE_STRINGS"
    let value = bundle.localizedString(forKey: key, value: defaultValue, table: nil)

    if value == defaultValue {
        return nil
    } else {
        return value
    }
}

private let referenceRegex = try! NSRegularExpression(pattern: "\\$\\{\\{([^}]*)\\}\\}", options: []) // swiftlint:disable:this force_try
private let interpolationRegex = try! NSRegularExpression(pattern: "\\{\\{([^}]*)\\}\\}", options: []) // swiftlint:disable:this force_try

/**
 Function that looks for references to other localization keys, syntax is ${{ <key> }}.

 - Example:
 In strings files you can have something like this:
 "some_key" = "aaa";
 "ref_key" = "Oh hello ${{ some_key }}";
 And when trying to localize "ref_key" the result will be "Oh hello aaa". Spaces inside brackets are optional.

 */
private func translateReferences(value: String, transform: (String) -> (String?)) -> String {
    var newValue = value

    while let match = referenceRegex.firstMatch(in: newValue, options: [], range: NSRange(location: 0, length: newValue.count)) {
        let startIndex = newValue.index(newValue.startIndex, offsetBy: match.range.location) // start string index
        let endIndex = newValue.index(startIndex, offsetBy: match.range.length) // end string index

        var key = String(newValue[startIndex..<endIndex]) // get matched string
        key = String(key.dropFirst(3)) // remove first ${{
        key = String(key.dropLast(2)) // remove last }}
        key = key.trimmingCharacters(in: CharacterSet.whitespaces) // trim spaces

        let translated = transform(key) ?? ""
        newValue.replaceSubrange(startIndex..<endIndex, with: translated)
    }

    return newValue
}

/**
 Function that looks for interpolation variables in string, syntax is {{ variable }}

 - Example:
 "intro.fmt" = "Hello {{ name }}";

 And when trying to localize "intro.fmt" with "Voloďa" in variable `name` the result will be "Hello Voloďa". Spaces inside brackets are optional.
 */
private func translateInterpolations(value: String, variableLookup: (String) -> (String?)) -> String {
    var newValue = value

    while let match = interpolationRegex.firstMatch(in: newValue, options: [], range: NSRange(location: 0, length: newValue.count)) {
        let startIndex = newValue.index(newValue.startIndex, offsetBy: match.range.location) // start string index
        let endIndex = newValue.index(startIndex, offsetBy: match.range.length) // end string index

        var key = String(newValue[startIndex..<endIndex]) // get matched string
        key = String(key.dropFirst(2)) // remove first {{
        key = String(key.dropLast(2)) // remove last }}
        key = key.trimmingCharacters(in: CharacterSet.whitespaces) // trim spaces

        let translated = variableLookup(key) ?? ""
        newValue.replaceSubrange(startIndex..<endIndex, with: translated)
    }

    return newValue
}

private func translateAll(key originalKey: String, variables: LocalizationVariables, bundle: Bundle = Bundle.main) -> String? {
    guard let originalValue = translate(key: originalKey) else {
        log.error("Localization: missing translation for key `\(originalKey)`")
        return nil
    }

    if originalValue.isEmpty {
        return nil
    }

    let referenced = translateReferences(value: originalValue) { refKey in
        if refKey == originalKey {
            fatalError("Localization: Recursive reference to key \(refKey)")
        }

        let val = translate(key: refKey)
        if val == nil {
            log.error("Localization: missing translation for key `\(refKey)` in original key `\(originalKey)`")
        }
        return val
    }

    let interpolated = translateInterpolations(value: referenced) { variableName in
        let val = variables[variableName]
        if val == nil {
            log.error("Localization: missing variable `\(variableName)` while translating key `\(originalKey)`")
        }
        return val
    }

    return interpolated
}
