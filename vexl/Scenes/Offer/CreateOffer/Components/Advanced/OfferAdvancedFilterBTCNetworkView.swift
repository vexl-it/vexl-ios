//
//  OfferAdvancedFilterTypeView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import SwiftUI

typealias OfferAdvancedBTCOption = OfferAdvancedFilterBTCNetworkView.Option

struct OfferAdvancedFilterBTCNetworkView: View {

    @Binding var selectedOptions: [Option]
    private let options: [Option] = [.lightning, .onChain]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(L.offerCreateAdvancedType())
                    .textStyle(.paragraph)

                Image(systemName: "info.circle.fill")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Appearance.Colors.gray3)

            MultipleOptionPickerView(selectedOptions: $selectedOptions,
                                     options: options,
                                     content: { option in
                Text(option.title)
            },
                                     action: nil)
        }
    }
}

extension OfferAdvancedFilterBTCNetworkView {
    enum Option: String {
        case lightning = "LIGHTING"
        case onChain = "ON_CHAIN"

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

#if DEBUG || DEVEL
struct OfferAdvancedFilterBTCNetworkViewPreview: PreviewProvider {
    static var previews: some View {
        OfferAdvancedFilterBTCNetworkView(
            selectedOptions: .constant([.lightning, .onChain])
        )
        .previewDevice("iPhone 11")
    }
}
#endif
