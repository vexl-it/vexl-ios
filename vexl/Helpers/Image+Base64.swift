//
//  Image+Base64.swift
//  vexl
//
//  Created by Diego Espinoza on 19/04/22.
//

import UIKit
import Combine

extension UIImage {
    var base64EncodedString: String? {
        jpegData(compressionQuality: 1)?.base64EncodedString()
    }

    var base64Publisher: AnyPublisher<String?, Never> {
        Future { [weak self] promise in
            let data = self?.jpegData(compressionQuality: 1)?.base64EncodedString()
            promise(.success(data))
        }
        .eraseToAnyPublisher()
    }
}

extension Data {
    var base64Publisher: AnyPublisher<String?, Never> {
        Future { promise in
            let data = self.base64EncodedString()
            promise(.success(data))
        }
        .eraseToAnyPublisher()
    }

    func compressImage(quality: Double) -> Data {
        guard let image = UIImage(data: self) else {
            return self
        }
        return image.jpegData(compressionQuality: quality) ?? self
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

    func dataFromBase64(withCompression compression: CGFloat) -> Data? {
        imageFromBase64?.jpegData(compressionQuality: compression)
    }
}
