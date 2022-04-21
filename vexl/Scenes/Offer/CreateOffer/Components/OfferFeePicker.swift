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
        VStack {
            Picker("", selection: $selectedOption) {
                ForEach(options, id: \.self) {
                    Text($0.title)
                        .textStyle(.paragraph)
                }
            }
            .padding(Appearance.GridGuide.point)
            .pickerStyle(.segmented)
            .background(Appearance.Colors.gray1)
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = R.color.gray2()
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: R.color.green5()!,
                                                                        .font: Appearance.TextStyle.paragraph.font], for: .selected)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: R.color.gray3()!,
                                                                        .font: Appearance.TextStyle.paragraph.font], for: .normal)
            }
        }
        .cornerRadius(Appearance.GridGuide.buttonCorner)
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
