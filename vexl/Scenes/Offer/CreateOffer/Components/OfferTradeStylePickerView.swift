//
//  OfferTradeStylePickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct OfferTradeStylePickerView: View {

    enum Option {
        case online
        case personal

        var title: String {
            switch self {
            case .online:
                return L.offerCreateTradeStyleOnline()
            case .personal:
                return L.offerCreateTradeStylePersonal()
            }
        }
    }

    @State private var selectedOption = Option.online
    var options = [Option.online, .personal]

    var body: some View {
        SegmentedPickerView(selectedOption: $selectedOption,
                            options: options) { option in
            Text(option.title)
                .foregroundColor(Appearance.Colors.green5)
        }
    }
}

#if DEBUG || DEVEL
struct OfferTradeStylePickerViewPreview: PreviewProvider {
    static var previews: some View {
        OfferTradeStylePickerView()
            .previewDevice("iPhone 11")
            .background(Color.black)
            .frame(height: 150)
    }
}
#endif
