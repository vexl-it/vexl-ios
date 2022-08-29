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
        private static let userApiHostname = "https://user.vexl.it"
        private static let contactsApiHostname = "https://contact.vexl.it"
        private static let offersApiHostname = "https://offer.vexl.it"
        private static let chatApiHostname = "https://chat.vexl.it"
        #elseif STAGING
        private static let userApiHostname = "https://user.vexl.staging.cleevio.io"
        private static let contactsApiHostname = "https://contact.vexl.staging.cleevio.io"
        private static let offersApiHostname = "https://offer.vexl.staging.cleevio.io"
        private static let chatApiHostname = "https://chat.vexl.staging.cleevio.io"
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
        static let mapyBaseURLString = "https://api.mapy.cz/"
    }

    // MARK: - Keychain keys

    enum KeychainKeys: RawRepresentable {
        init?(rawValue: String) { nil }

        case facebookID
        case facebookToken
        case facebookHash
        case facebookSignature
        case localEncryptionKey
        case userCountryCode

        var rawValue: String {
            switch self {
            case .localEncryptionKey:
                return "aesKey"
            case .facebookID:
                return "facebookID"
            case .facebookToken:
                return "facebookToken"
            case .facebookHash:
                return "facebookHash"
            case .facebookSignature:
                return "facebookSignature"
            case .userCountryCode:
                return "userCountryCode"
            }
        }
    }

    // MARK: - Offer initial data

    struct OfferInitialData {
        static let minOffer: Int = 0
        static let maxOffer: Int = 10_000
        static let maxOfferCZK: Int = 250_000
        static let minFee: Double = 1
        static let maxFee: Double = 10
        static let currency: Currency = .usd
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

    static let inboxSyncPollInterval: TimeInterval = 10
    // TODO: set bitcoin polling to some more apropriate value when BE solves issue (previously was 30)
    static let bitcoinPollInterval: TimeInterval = 9_000_000_000

    static let notAvailable = "N/A"

    static let fakePushNotificationToken = "03df25c845d460bcdad7802d2vf6fc1dfde97283bf75cc993eb6dca835ea2e2f"

    // MARK: - Units used for converting time to seconds

    static let daysToSecondsMultiplier: TimeInterval = 86_400
    static let weeksToSecondsMultiplier: TimeInterval = 604_800
    static let monthsToSecondsMultiplier: TimeInterval = 2_592_000

    static let defaultOfferDeleteTime = "14" // days will be selected as default too

    #if APPSTORE
    // TODO: would be better to obfuscate this
    static let contactsHashingPassword = "9cf02ca3b233f17160e71b0db098f95396e73f27ef672dda482a6566d8e29484"
    #else
    static let contactsHashingPassword = "VexlVexl"
    #endif

    static let supportEmail = "support@vexl.it"

    static let randomNameSyllables = [
        "bo", "da", "ga", "ge", "chi", "ka", "ko", "ku",
        "ma", "mi", "mo", "na", "no", "ro", "ri", "ru",
        "sa", "se", "su", "shi", "she", "sha", "sho",
        "ta", "te", "to", "yu", "za", "zo"
    ]

    static let maxPhoneNumberDigits = 9
    static let registrationSteps = 3
}
