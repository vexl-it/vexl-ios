//
//  Constants.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import UIKit

typealias L = R.string.localizable

// swiftlint:disable type_property_specifier
struct Constants {
    // MARK: - API

    struct API {
        #if APPSTORE
        private static let userApiHostname = "https://user.vexl.devel.cleevio.io"
        private static let contactsApiHostname = "https://contact.vexl.devel.cleevio.io"
        private static let offersApiHostname = "https://offer.vexl.devel.cleevio.io"
        private static let chatApiHostname = "https://chat.vexl.devel.cleevio.io"
        #else
        private static let userApiHostname = "https://user.vexl.devel.cleevio.io"
        private static let contactsApiHostname = "https://contact.vexl.devel.cleevio.io"
        private static let offersApiHostname = "https://offer.vexl.devel.cleevio.io"
        private static let chatApiHostname = "https://chat.vexl.devel.cleevio.io"
        #endif

        private static let apiVersion = "v1/"

        static let baseURLString = ""
        static let userBaseURLString = "\(userApiHostname)/api/\(apiVersion)"
        static let contactsBaseURLString = "\(contactsApiHostname)/api/\(apiVersion)"
        static let offersBaseURLString = "\(offersApiHostname)/api/\(apiVersion)"
        static let chatBaseURLString = "\(chatApiHostname)/api/\(apiVersion)"
    }

    // MARK: - Keychain keys

    enum KeychainKeys: String {
        case dummyKey
        case accessToken
        case refreshToken
        case userSecurity
    }

    // MARK: - Decoder

    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatters.dateApiFormatter)
        return decoder
    }()

    static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Formatters.dateApiFormatter)
        return encoder
    }()

    static let jpegFormat = "jpeg"

    static let elipticCurve: Curve = .init(rawValue: UInt32(10))

    static let currencySymbol = "$"

    static let pageMaxLimit = 1_000

    static let bitcoinPollInterval: TimeInterval = 30

    static let notAvailable = "N/A"

    // MARK: - Units used for converting time to seconds

    static let daysToSecondsMultiplier: TimeInterval = 86_400
    static let weeksToSecondsMultiplier: TimeInterval = 604_800
    static let monthsToSecondsMultiplier: TimeInterval = 2_592_000

    static let defaultDeleteTime = "7" // days will be selected as default too

    // TODO: - change to real password when available
    
    static let contactsHashingPassword = "VexlVexl"
}
