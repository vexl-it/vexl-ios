//
//  OfferCurrencyPickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 27/07/22.
//

import SwiftUI

struct OfferCurrencyPickerView: View {

    @Binding var selectedOption: Currency

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(R.image.offer.coins.name)

                Text(L.userProfileCurrencyTitle())
                    .textStyle(.titleSemiBold)
                    .foregroundColor(Appearance.Colors.whiteText)
            }

            SingleOptionPickerView(selectedOption: $selectedOption,
                                   options: Currency.allCases,
                                   content: { option in
                Text(option.label)
                    .frame(maxWidth: .infinity, alignment: .center)
            },
                                   action: nil)
                .padding(Appearance.GridGuide.tinyPadding)
                .background(Appearance.Colors.gray1)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

#if DEBUG || DEVEL
struct OfferCurrencyPickerViewPreview: PreviewProvider {
    static var previews: some View {
        OfferCurrencyPickerView(selectedOption: .constant(.usd))
            .previewDevice("iPhone 11")
            .background(Color.black)
            .frame(width: 400, height: 150)
    }
}
#endif
