//
//  OfferTriggersView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/04/22.
//

import SwiftUI

struct OfferTriggersView: View {

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

    @State var selectedOption: Option = .below
    @State var isActiveExpanded = true

    @State var amount: String
    let options: [Option] = [.below, .above]

    let currency: String = "$"

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "clock")

                Text(L.offerCreateTriggerTitle())
                    .textStyle(.h3)

                Spacer()

                Image(systemName: "chevron.down")
            }
            .foregroundColor(Appearance.Colors.whiteText)

            HStack {
                Text(L.offerCreateTriggerActive())
                    .textStyle(.paragraph)

                Spacer()

                Button {
                    isActiveExpanded.toggle()
                } label: {
                    Image(systemName: isActiveExpanded ? "xmark" : "plus")
                }
            }
            .padding(.top, Appearance.GridGuide.mediumPadding1)
            .foregroundColor(Appearance.Colors.gray3)

            if isActiveExpanded {
                HStack {
                    SingleOptionPickerView(selectedOption: $selectedOption,
                                           options: options,
                                           content: { option in
                        Text(option.title)
                    },
                                           action: { index in
                        print("index \(index)")
                    })

                    Spacer()

                    Rectangle()
                        .frame(width: 2)
                        .foregroundColor(Appearance.Colors.gray2)

                    Spacer()

                    HStack(spacing: Appearance.GridGuide.tinyPadding) {
                        Text(currency)
                            .textStyle(.h3)
                            .foregroundColor(Appearance.Colors.green5)

                        TextField("", text: $amount)
                            .textStyle(.h3)
                            .foregroundColor(Appearance.Colors.green5)
                            .keyboardType(.numberPad)
                    }
                    .frame(width: UIScreen.main.width * 0.33)
                }
                .padding(Appearance.GridGuide.point)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Appearance.Colors.gray1)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
            }
        }
    }
}

#if DEBUG || DEVEL
struct OfferTriggersViewPreview: PreviewProvider {
    static var previews: some View {
        OfferTriggersView(amount: "123")
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
