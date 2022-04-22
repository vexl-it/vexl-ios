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

struct SingleOptionPickerView<Option: Hashable, Content: View>: View {

    @Binding var selectedOption: Option
    let options: [Option]
    let content: (Option) -> Content
    let action: (Option) -> Void

    var body: some View {
        HStack {
            ForEach(options, id: \.self) { option in
                Button {
                    selectedOption = option
                    action(option)
                } label: {
                    content(option)
                }
                .padding()
                .foregroundColor(option == selectedOption ? Appearance.Colors.green5 : Appearance.Colors.gray3)
                .background(option == selectedOption ? Appearance.Colors.gray2 : Appearance.Colors.gray1)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
            }
        }
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
