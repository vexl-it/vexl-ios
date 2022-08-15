//
//  OfferFeePicker.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

typealias OfferFeeOption = OfferFeePickerView.Option

struct OfferFeePickerView: View {

    let feeLabel: String
    let minValue: Double
    let maxValue: Double
    @Binding var selectedOption: Option
    @Binding var feeValue: Double
    private let options = [Option.withoutFee, .withFee]

    var body: some View {
        VStack(alignment: .leading) {
            SegmentedPickerView(selectedOption: $selectedOption,
                                options: options) { option in
                Text(option.title)
            }

            if selectedOption == .withFee {
                HLine(color: Appearance.Colors.gray2,
                      height: 1)
                    .padding(.top, Appearance.GridGuide.padding)
                    .padding(.horizontal, Appearance.GridGuide.point)

                Text(feeLabel)
                    .textStyle(.paragraphMedium)
                    .foregroundColor(Appearance.Colors.whiteText)
                    .padding(Appearance.GridGuide.padding)

                SliderView(
                    thumbColor: UIColor(Appearance.Colors.whiteText),
                    minTrackColor: UIColor(Appearance.Colors.whiteText),
                    maxTrackColor: UIColor(Appearance.Colors.gray2),
                    minValue: minValue,
                    maxValue: maxValue,
                    value: $feeValue
                )
                .padding(.horizontal, Appearance.GridGuide.point)
                .padding(.bottom, Appearance.GridGuide.padding)
            }
        }
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

extension OfferFeePickerView {
    enum Option: String, CaseIterable {
        case withoutFee = "WITHOUT_FEE"
        case withFee = "WITH_FEE"

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
        OfferFeePickerView(feeLabel: "10%",
                           minValue: 1,
                           maxValue: 10,
                           selectedOption: .constant(.withoutFee),
                           feeValue: .constant(5))
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
