//
//  OfferFeePicker.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

typealias OfferFeeOption = OfferFeePickerView.Option

struct OfferFeePickerView: View {

    @Binding var selectedOption: Option
    @Binding var feeValue: Double
    var options = [Option.withoutFee, .withFee]

    var body: some View {
        VStack(alignment: .leading) {
            SegmentedPickerView(selectedOption: $selectedOption,
                                options: options) { option in
                Text(option.title)
                    .foregroundColor(Appearance.Colors.green5)
            }

            if selectedOption == .withFee {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Appearance.Colors.gray2)
                    .padding(.top, Appearance.GridGuide.padding)
                    .padding(.horizontal, Appearance.GridGuide.point)

                Text("< 10%")
                    .textStyle(.paragraphMedium)
                    .foregroundColor(Appearance.Colors.green5)
                    .padding(.horizontal, Appearance.GridGuide.padding)

                SliderView(thumbColor: R.color.green5()!,
                           minTrackColor: R.color.green5(),
                           maxTrackColor: R.color.gray2(),
                           value: $feeValue)
                    .padding(.horizontal, Appearance.GridGuide.point)
                    .padding(.bottom, Appearance.GridGuide.padding)
            }
        }
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

extension OfferFeePickerView {
    enum Option {
        case withFee
        case withoutFee

        var title: String {
            switch self {
            case .withoutFee:
                return L.offerCreateFeeNone()
            case .withFee:
                return L.offerCreateFeeOk()
            }
        }
    }
}

#if DEBUG || DEVEL
struct OfferFeePickerViewPreview: PreviewProvider {
    static var previews: some View {
        OfferFeePickerView(selectedOption: .constant(.withoutFee),
                           feeValue: .constant(5))
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
