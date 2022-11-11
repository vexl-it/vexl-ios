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
        VStack {
            SegmentedPickerView(selectedOption: $selectedOption,
                                options: options) { option in
                Text(option.title)
                    .foregroundColor(Appearance.Colors.whiteText)
            }
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)

            if selectedOption == .online {
                HStack(alignment: .top) {
                    Image(R.image.offer.infoPurple.name)
                    Text(L.offerWidgetLocationWarning())
                        .foregroundColor(Appearance.Colors.pink100)
                }
                .padding(Appearance.GridGuide.padding)
                .background(Appearance.Colors.pink20)
                .cornerRadius(Appearance.GridGuide.containerCorner)
            }
        }
    }
}

extension OfferTradeLocationPickerView {
    enum Option: String {
        case online = "ONLINE"
        case personal = "IN_PERSON"

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
