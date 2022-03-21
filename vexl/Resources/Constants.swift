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
        private static let apiHostname = "https://user.vexl.devel.cleevio.io"
        #else
        private static let apiHostname = "https://user.vexl.devel.cleevio.io"
        #endif

        private static let apiVersion = "v1/"

        static let baseURLString = "\(apiHostname)/api/\(apiVersion)"
    }

    // MARK: - Keychain keys

    enum KeychainKeys: String {
        case dummyKey
        case accessToken
        case refreshToken
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
}
