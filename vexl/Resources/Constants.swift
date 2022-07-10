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

    enum KeychainKeys: RawRepresentable {
        init?(rawValue: String) { nil }

        case userSecurity
        case userSignature
        case privateKey(publicKey: String)

        var rawValue: String {
            switch self {
            case .userSecurity:
                return "userSecurity"
            case .privateKey(let publicKey):
                return "publickey-\(publicKey)"
            case .userSignature:
                return "userSignature"
            }
        }
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
    static let imageCompressionQuality: CGFloat = 0.25

    static let elipticCurve: Curve = .init(rawValue: UInt32(10))

    static let currencySymbol = "$"

    static let pageMaxLimit = 1_000

    static let bitcoinPollInterval: TimeInterval = 30
    static let inboxSyncPollInterval: TimeInterval = 60

    static let notAvailable = "N/A"

    // TODO: - remove when we have real random names
    static let pushNotificationToken = "03df25c845d460bcdad7802d2vf6fc1dfde97283bf75cc993eb6dca835ea2e2f"
    static let randomName = "Random Name"

    // MARK: - Units used for converting time to seconds

    static let daysToSecondsMultiplier: TimeInterval = 86_400
    static let weeksToSecondsMultiplier: TimeInterval = 604_800
    static let monthsToSecondsMultiplier: TimeInterval = 2_592_000

    static let defaultDeleteTime = "7" // days will be selected as default too

    // TODO: - change to real password when available

    static let contactsHashingPassword = "VexlVexl"
}
