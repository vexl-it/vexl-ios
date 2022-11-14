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
        VStack(spacing: Appearance.GridGuide.padding) {
            SingleOptionPickerView(
                selectedOption: $selectedOption,
                options: options,
                content: { option in
                    Text(option.title)
                        .foregroundColor(Appearance.Colors.whiteText)
                        .frame(maxWidth: .infinity, alignment: .center)
                },
                action: nil
            )
            .padding(Appearance.GridGuide.tinyPadding)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)

            if selectedOption == .online {
                HStack(alignment: .top) {
                    Image(R.image.offer.infoPurple.name)
                        .padding(.top, Appearance.GridGuide.tinyPadding)
                    Text(L.offerWidgetLocationWarning())
                        .foregroundColor(Appearance.Colors.pink100)
                }
                .frame(maxWidth: .infinity, alignment: .center)
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
