//
//  OfferAmountRangeView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 24.05.2022.
//

import SwiftUI

struct OfferAmountRangeView: View {
    let currency: Currency
    @Binding var currentValue: ClosedRange<Int>
    let sliderBounds: ClosedRange<Int>

    var minAmountTextFieldViewModel: OfferAmountTextFieldViewModel
    var maxAmountTextFieldViewModel: OfferAmountTextFieldViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {
            HStack(spacing: Appearance.GridGuide.point) {
                Image(systemName: "plus.forwardslash.minus")

                Text(L.offerCreateStatusAmountTitle())
                    .textStyle(.titleSemiBold)
            }
            .foregroundColor(Appearance.Colors.whiteText)

            HStack(spacing: Appearance.GridGuide.mediumPadding2) {
                Text(L.offerCreateAmountMinTitle())
                    .textStyle(.paragraphMedium)
                    .foregroundColor(Appearance.Colors.gray4)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(L.offerCreateAmountMaxTitle())
                    .textStyle(.paragraphMedium)
                    .foregroundColor(Appearance.Colors.gray4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)

            HStack(alignment: .center, spacing: Appearance.GridGuide.point) {
                OfferAmountTextField(
                    viewModel: minAmountTextFieldViewModel
                )

                Text("–")
                    .textStyle(.paragraphMedium)
                    .foregroundColor(Appearance.Colors.gray4)

                OfferAmountTextField(
                    viewModel: maxAmountTextFieldViewModel
                )
            }

            RangePickerView(currency: currency,
                            currentValue: $currentValue,
                            sliderBounds: sliderBounds)
        }
    }
}

#if DEBUG || DEVEL
import Combine

struct OfferAmountRangeViewPreview: PreviewProvider {

    static var previews: some View {
        OfferAmountRangeView(currency: .usd,
                             currentValue: .constant(3...8),
                             sliderBounds: 1...10,
                             minAmountTextFieldViewModel: .init(
                                type: .min,
                                currentAmountRangePublisher: Just(0...10_000).eraseToAnyPublisher(),
                                sliderBoundsPublisher: Just(0...10_000).eraseToAnyPublisher(),
                                currencyPublisher: Just(.usd).eraseToAnyPublisher(),
                                rangeSetter: { _ in }
                             ),
                             maxAmountTextFieldViewModel: .init(
                                type: .min,
                                currentAmountRangePublisher: Just(0...10_000).eraseToAnyPublisher(),
                                sliderBoundsPublisher: Just(0...10_000).eraseToAnyPublisher(),
                                currencyPublisher: Just(.usd).eraseToAnyPublisher(),
                                rangeSetter: { _ in }
                             ))
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
