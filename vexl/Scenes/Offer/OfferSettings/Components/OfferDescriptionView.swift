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
                .textStyle(.titleSemiBold)
                .foregroundColor(Appearance.Colors.whiteText)

            ExpandingTextView(
                placeholder: L.offerCreateDescriptionPlaceholder(),
                text: $text,
                isFirstResponder: false
            )
        }
    }
}
