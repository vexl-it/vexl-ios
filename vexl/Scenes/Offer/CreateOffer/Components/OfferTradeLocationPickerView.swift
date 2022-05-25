//
//  OfferTradeStylePickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

typealias OfferTradeLocationOption = OfferTradeLocationPickerView.Option

struct OfferTradeLocationPickerView: View {

    @Binding var selectedOption: Option
    private let options = [Option.online, .personal]

    var body: some View {
        SegmentedPickerView(selectedOption: $selectedOption,
                            options: options) { option in
            Text(option.title)
                .foregroundColor(Appearance.Colors.whiteText)
        }
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

extension OfferTradeLocationPickerView {
    enum Option: String {
        case online = "ONLINE_OK"
        case personal = "ONLY_IN_PERSON"

        var title: String {
            switch self {
            case .online:
                return L.offerCreateTradeStyleOnline()
            case .personal:
                return L.offerCreateTradeStylePersonal()
            }
        }
    }
}

#if DEBUG || DEVEL
struct OfferTradeStylePickerViewPreview: PreviewProvider {
    static var previews: some View {
        OfferTradeLocationPickerView(selectedOption: .constant(.online))
            .previewDevice("iPhone 11")
            .background(Color.black)
            .frame(height: 150)
    }
}
#endif
