//
//  OfferAdvancedFilterTypeView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import SwiftUI

typealias OfferAdvancedTypeOption = OfferAdvancedFilterTypeView.Option

struct OfferAdvancedFilterTypeView: View {

    @Binding var selectedOptions: [Option]
    let options: [Option] = [.lightning, .onChain]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(L.offerCreateAdvancedType())
                    .textStyle(.paragraph)

                Spacer()

                Image(systemName: "arrow.clockwise")
            }
            .foregroundColor(Appearance.Colors.gray3)

            MultipleOptionPickerView(selectedOptions: $selectedOptions,
                                     options: options,
                                     content: { option in
                Text(option.title)
            },
                                     action: { option, _ in
                print(option.title)
            })
        }
    }
}

extension OfferAdvancedFilterTypeView {
    enum Option {
        case lightning, onChain

        var title: String {
            switch self {
            case .lightning:
                return L.offerCreateAdvancedTypeLightning()
            case .onChain:
                return L.offerCreateAdvancedTypeChain()
            }
        }
    }
}
