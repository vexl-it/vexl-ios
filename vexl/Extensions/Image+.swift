//
//  Image+.swift
//  vexl
//
//  Created by Diego Espinoza on 11/04/22.
//

import SwiftUI

extension Image {
    init(data: Data?, placeholder: String) {
        if let data = data, let uiImage = UIImage(data: data) {
            self = Image(uiImage: uiImage)
        } else {
            self = Image(placeholder)
        }
    }
}
