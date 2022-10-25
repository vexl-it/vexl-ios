//
//  String+Crypto.swift
//  vexl
//
//  Created by Adam Salih on 24.04.2022.
//

import Foundation

extension String: Encryptable {
    var asString: String { self }

    func encodeEncryptionVersion<T: RawRepresentable>(version: T) -> String where T.RawValue == Int {
        "\(version.rawValue)" + self
    }

    func decodeEncryptionVersion<T: RawRepresentable>(version: T.Type) -> (T, String)? where T.RawValue == Int {
        guard let versionString = self.first,
            let version = Int("\(versionString)"),
            let enumeratedVersion = T(rawValue: version) else {
            return nil
        }
        let strippedVersionString = String(self.dropFirst())
        return (enumeratedVersion, strippedVersionString)
    }
}
