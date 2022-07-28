//
//  OfferPaymentMethodView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

typealias OfferPaymentMethodOption = OfferPaymentMethodView.Option

struct OfferPaymentMethodView: View {

    @Binding var selectedOptions: [Option]
    private let options: [Option] = [.cash, .revolut, .bank]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "creditcard")

                Text(L.offerCreatePaymentMethodTitle())
                    .textStyle(.titleSemiBold)
            }
            .foregroundColor(Appearance.Colors.whiteText)

            MultipleOptionPickerView(selectedOptions: $selectedOptions,
                                     options: options,
                                     content: { option in
                Text(option.title)
            },
                                     action: nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension OfferPaymentMethodView {
    enum Option: String {
        case cash = "CASH"
        case revolut = "REVOLUT"
        case bank = "BANK"

        var title: String {
            switch self {
            case .cash:
                return L.offerCreatePaymentMethodCash()
            case .revolut:
                return L.offerCreatePaymentMethodRevolut()
            case .bank:
                return L.offerCreatePaymentMethodBank()
            }
        }

        var iconName: String {
            switch self {
            case .cash:
                return R.image.marketplace.cash.name
            case .revolut:
                return R.image.marketplace.revolut.name
            case .bank:
                return R.image.marketplace.bank.name
            }
        }
    }
}

#if DEBUG || DEVEL
struct OfferPaymentMethodViewPreview: PreviewProvider {
    static var previews: some View {
        OfferPaymentMethodView(selectedOptions: .constant([]))
            .previewDevice("iPhone 11")
            .background(Color.black)
            .frame(height: 150)
    }
}
#endif
