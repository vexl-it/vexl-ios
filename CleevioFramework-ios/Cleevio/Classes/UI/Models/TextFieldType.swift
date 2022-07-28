//
//  TextFieldType.swift
//  CleevioUI
//
//  Created by Thành Đỗ Long on 30.11.2020.
//

import UIKit

public enum TextFieldType {
    case `default`
    case countryPicker
    case password
    case newPassword
    case emailAddress
    case telephoneNumber
    case givenName
    case familyName
    case disabled
    case numberPad

    var keyboardType: UIKeyboardType {
        switch self {
        case .emailAddress:
            return .emailAddress
        case .telephoneNumber:
            return .phonePad
        case .numberPad:
            return .numberPad
        default:
            return .default
        }
    }

    var textContentType: UITextContentType? {
        switch self {
        case .emailAddress:
            return .emailAddress
        case .telephoneNumber:
            return .telephoneNumber
        case .password:
            return .password
        case .newPassword:
            return .newPassword
        case .givenName:
            return .givenName
        case .familyName:
            return .familyName
        default:
            return nil
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        switch self {
        case .familyName, .givenName:
            return .words
        default:
            return .none
        }
    }
}
