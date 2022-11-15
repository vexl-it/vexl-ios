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
        private static let offersApiHostname = "https://offer2.vexl.it"
        private static let chatApiHostname = "https://chat.vexl.it"
        #elseif STAGING
        private static let userApiHostname = "https://user.vexl.staging.cleevio.io"
        private static let contactsApiHostname = "https://contact.vexl.staging.cleevio.io"
        private static let offersApiHostname = "https://offer2.vexl.staging.cleevio.io"
        private static let chatApiHostname = "https://chat.vexl.staging.cleevio.io"
        #else
        private static let userApiHostname = "https://user.vexl.devel.cleevio.io"
        private static let contactsApiHostname = "https://contact.vexl.devel.cleevio.io"
        private static let offersApiHostname = "https://offer2.vexl.devel.cleevio.io"
        private static let chatApiHostname = "https://chat.vexl.devel.cleevio.io"
        #endif

        static let baseURLString = ""
        static let userBaseURLString = "\(userApiHostname)/api/"
        static let contactsBaseURLString = "\(contactsApiHostname)/api/"
        static let offersBaseURLString = "\(offersApiHostname)/api/"
        static let chatBaseURLString = "\(chatApiHostname)/api/"
        static let mapyBaseURLString = "https://api.mapy.cz/"

        enum Version: String {
            case v1
            case v2
        }
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
        case phoneRegistration

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
            case .phoneRegistration:
                return "phoneRegistration"
            }
        }
    }

    // MARK: - Offer initial data

    struct OfferInitialData {
        static let minOffer: Int = 0
        static let maxOffer: Int = 200
        static let maxOfferCZK: Int = 250
        static let minFee: Double = 1
        static let maxFee: Double = 10

        static let maxOfferStep: Int = 50
        static let maxOfferCZKStep: Int = 1_000
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

    static let maxLogLimit = 100

    static let inboxSyncPollInterval: TimeInterval = 10
    // TODO: set bitcoin polling to some more apropriate value when BE solves issue (previously was 30)
    static let bitcoinPollInterval: TimeInterval = 9_000_000_000

    static let notAvailable = "N/A"

    static let fakePushNotificationToken = "03df25c845d460bcdad7802d2vf6fc1dfde97283bf75cc993eb6dca835ea2e2f"

    // MARK: - Units used for converting time to seconds

    static let daysToSecondsMultiplier: TimeInterval = 86_400
    static let weeksToSecondsMultiplier: TimeInterval = 604_800
    static let monthsToSecondsMultiplier: TimeInterval = 2_592_000

    static let defaultOfferDeleteTime = "30" // days will be selected as default too

    #if APPSTORE
    // TODO: would be better to obfuscate this
    static let contactsHashingPassword = "9cf02ca3b233f17160e71b0db098f95396e73f27ef672dda482a6566d8e29484"
    #else
    static let contactsHashingPassword = "VexlVexl"
    #endif

    static let supportEmail = "support@vexl.it"

    static let numberOfSyllablesForName = 4
    static let randomNameSyllables = [
        "bo", "da", "ga", "ge", "chi", "ka", "ko", "ku",
        "ma", "mi", "mo", "na", "no", "ro", "ri", "ru",
        "sa", "se", "su", "shi", "she", "sha", "sho",
        "ta", "te", "to", "yu", "za", "zo"
    ]

    static let encryptionKeySplitAmount = 10
    static let maxPhoneNumberDigits = 9
    static let registrationSteps = 3
    static let maxOfferDescriptionCount = 140
    static let maxNumberOfLocations = 5
    static let maxImageSize: CGFloat = 1_024
    static let numberOfOffersForLockedScreen = "98 734"
    static let pullToRefreshActivationOffset: CGFloat = 70
}
