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
                    .textStyle(.h3)
            }
            .foregroundColor(Appearance.Colors.whiteText)

            MultipleOptionPickerView(selectedOptions: $selectedOptions,
                                     options: options,
                                     content: { option in
                Text(option.title)
            },
                                     action: { option, _ in
                print(option.title)
            })
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension OfferPaymentMethodView {
    enum Option {
        case cash
        case revolut
        case bank

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
