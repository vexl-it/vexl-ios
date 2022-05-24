//
//  OfferAmountRangeView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 24.05.2022.
//

import SwiftUI

struct OfferAmountRangeView: View {
    let currencySymbol: String
    let currentValue: Binding<ClosedRange<Int>>
    let sliderBounds: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: Appearance.GridGuide.point) {
                Image(systemName: "plus.forwardslash.minus")

                Text(L.offerCreateStatusAmountTitle())
                    .textStyle(.h3)
            }
            .foregroundColor(Appearance.Colors.whiteText)

            RangePickerView(currencySymbol: currencySymbol, currentValue: currentValue, sliderBounds: sliderBounds)
        }
    }
}

#if DEBUG || DEVEL
struct OfferAmountRangeViewPreview: PreviewProvider {
    static var previews: some View {
        OfferAmountRangeView(currencySymbol: "$",
                             currentValue: .constant(3...8),
                             sliderBounds: 1...10)
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
