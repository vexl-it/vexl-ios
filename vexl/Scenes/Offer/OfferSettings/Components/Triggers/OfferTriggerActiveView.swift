//
//  OfferTriggerActiveView.swift
//  vexl
//
//  Created by Diego Espinoza on 11/07/22.
//

import SwiftUI

struct OfferTriggerActiveView: View {

    let currencySymbol: String
    @Binding var selectedOption: OfferTrigger
    @Binding var activeAmount: String

    var body: some View {
        VStack(alignment: .leading) {

            Text(L.offerCreateTriggerActive())
                .foregroundColor(Appearance.Colors.gray3)
                .textStyle(.paragraph)
                .padding(.top, Appearance.GridGuide.padding)

            HStack(spacing: .zero) {
                SingleOptionPickerView(selectedOption: $selectedOption,
                                       options: [OfferTrigger.above, OfferTrigger.below],
                                       content: { option in
                    Text(option.title)
                        .frame(minWidth: 50)
                },
                                       action: nil)
                    .frame(maxWidth: .infinity)

                VLine(color: Appearance.Colors.gray3,
                      width: 1)
                    .padding(.all, Appearance.GridGuide.point)

                HStack(spacing: .zero) {
                    Text(currencySymbol)
                        .textStyle(.titleSmallBold)
                        .foregroundColor(Appearance.Colors.yellow100)

                    TextField("", text: $activeAmount)
                        .multilineTextAlignment(.center)
                        .textStyle(.h3)
                        .foregroundColor(Appearance.Colors.yellow100)
                        .frame(maxWidth: .infinity)
                        .keyboardType(.numberPad)
                }
            }
            .padding(Appearance.GridGuide.tinyPadding)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

#if DEBUG || DEVEL
struct OfferTriggerActiveViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            OfferTriggerActiveView(currencySymbol: "$",
                                   selectedOption: .constant(.none),
                                   activeAmount: .constant("10000"))

            OfferTriggerActiveView(currencySymbol: "$",
                                   selectedOption: .constant(.above),
                                   activeAmount: .constant("10000"))
        }
        .background(Color.black)
    }
}
#endif
