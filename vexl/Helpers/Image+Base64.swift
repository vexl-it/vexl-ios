//
//  Image+Base64.swift
//  vexl
//
//  Created by Diego Espinoza on 19/04/22.
//

import UIKit

extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}

extension String {
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }

    var dataFromBase64: Data? {
        Data(base64Encoded: self, options: .ignoreUnknownCharacters)
    }
}
