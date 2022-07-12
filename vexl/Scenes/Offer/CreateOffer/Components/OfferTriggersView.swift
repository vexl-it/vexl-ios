//
//  OfferTriggersView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/04/22.
//

import SwiftUI

struct OfferTriggersView: View {

    @State private var selectedOption: Option = .below
    @State private var isActiveExpanded = true

    private let options: [Option] = [.below, .above]
    private let currency: String = Constants.currencySymbol

    @Binding var deleteTime: String
    @Binding var deleteTimeUnit: OfferTriggerDeleteTimeUnit

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "clock")

                Text(L.offerCreateTriggerTitle())
                    .textStyle(.title)

                Spacer()

                Image(systemName: "chevron.down")
            }
            .foregroundColor(Appearance.Colors.whiteText)

            if isActiveExpanded {
                OfferTriggerDeleteView(time: $deleteTime,
                                       timeUnit: $deleteTimeUnit)
            }
        }
    }
}

extension OfferTriggersView {
    enum Option {
        case below, above

        var title: String {
            switch self {
            case .below:
                return L.offerCreateTriggerBelow()
            case .above:
                return L.offerCreateTriggerAbove()
            }
        }
    }
}

#if DEBUG || DEVEL
struct OfferTriggersViewPreview: PreviewProvider {
    static var previews: some View {
        OfferTriggersView(deleteTime: .constant("30"),
                          deleteTimeUnit: .constant(.days))
            .background(Color.black)
    }
}
#endif
