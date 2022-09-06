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
            HStack {
                Image(R.image.offer.description.name)

                Text(L.offerCreateDescription())
                    .multilineTextAlignment(.leading)
                    .textStyle(.titleSemiBold)
                    .foregroundColor(Appearance.Colors.whiteText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(text.count)/\(Constants.maxOfferDescriptionCount)")
                    .textStyle(.paragraphSmallMedium)
                    .foregroundColor(Appearance.Colors.whiteText)
            }

            ExpandingTextView(
                placeholder: L.offerCreateDescriptionPlaceholder(),
                text: $text,
                isFirstResponder: false
            )
        }
    }
}
