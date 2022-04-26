//
//  OfferDescriptionView.swift
//  vexl
//
//  Created by Diego Espinoza on 27/04/22.
//

import SwiftUI

struct OfferDescriptionView: View {

    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(L.offerCreateDescription())
                .textStyle(.h3)
                .foregroundColor(Appearance.Colors.whiteText)

            PlaceholderTextField(placeholder: "Enter Description",
                                 textColor: Appearance.Colors.whiteText,
                                 text: $text)
        }
    }
}
