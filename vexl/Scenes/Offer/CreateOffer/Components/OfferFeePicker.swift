//
//  OfferFeePicker.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct OfferFeePickerView: View {

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

    @State private var selectedOption = Option.withoutFee
    var options = [Option.withoutFee, .withFee]

    var body: some View {
        SegmentedPickerView(selectedOption: $selectedOption,
                            options: options) { option in
            Text(option.title)
                .foregroundColor(Appearance.Colors.green5)
        }
    }
}

#if DEBUG || DEVEL
struct OfferFeePickerViewPreview: PreviewProvider {
    static var previews: some View {
        OfferFeePickerView()
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
