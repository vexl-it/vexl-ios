//
//  FetchImage.swift
//  vexl
//
//  Created by Diego Espinoza on 19/04/22.
//

import SwiftUI
import Kingfisher

struct FetchImage: View {

    let url: URL?
    let placeholder: String

    var body: some View {
        KFImage(url)
            .placeholder {
                Image(placeholder)
            }
            .resizable()
    }
}
