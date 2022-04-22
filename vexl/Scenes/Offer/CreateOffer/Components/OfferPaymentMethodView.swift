//
//  OfferPaymentMethodView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct OfferPaymentMethodView: View {

    enum Option {
        case cash
        case revolut
        case bank

        var title: String {
            switch self {
            case .cash:
                return "Cash"
            case .revolut:
                return "Revolut"
            case .bank:
                return "Bank"
            }
        }
    }

    var options: [Option] = [.cash, .revolut, .bank]
    @State var selectedOption: Option = .cash

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "creditcard")

                Text("Payment Method")
                    .textStyle(.h3)
            }
            .foregroundColor(Appearance.Colors.whiteText)

            SingleOptionPickerView(selectedOption: $selectedOption,
                                   options: options,
                                   content: { option in
                Text(option.title)
            },
                                   action: { option in
                print(option.title)
            })
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG || DEVEL
struct OfferPaymentMethodViewPreview: PreviewProvider {
    static var previews: some View {
        OfferPaymentMethodView()
            .previewDevice("iPhone 11")
            .background(Color.black)
            .frame(height: 150)
    }
}
#endif
