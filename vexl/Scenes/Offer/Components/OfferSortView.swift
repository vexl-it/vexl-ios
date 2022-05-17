//
//  OfferSortView.swift
//  vexl
//
//  Created by Diego Espinoza on 17/05/22.
//

import SwiftUI

typealias OfferSortOption = OfferSortView.Option

struct OfferSortView: View {

    let numberOfOffers: Int
    @Binding var sortingOption: Option

    var body: some View {
        HStack {
            Text(L.offerSortActive("\(numberOfOffers)"))
                .foregroundColor(Appearance.Colors.gray3)
                .textStyle(.paragraphMedium)

            Spacer()

            Menu {
                ForEach(Option.allCases) { option in
                    Button(option.title) {
                        sortingOption = option
                    }
                }
            } label: {
                Text(sortingOption.title)
                    .foregroundColor(Appearance.Colors.gray3)
                    .textStyle(.paragraphMedium)
            }
            .padding(.vertical, Appearance.GridGuide.point)
            .padding(.horizontal, Appearance.GridGuide.padding)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .padding(Appearance.GridGuide.point)
    }
}

extension OfferSortView {

    enum Option: Identifiable, CaseIterable {

        case newest
        case oldest

        var id: Option {
            self
        }

        var title: String {
            switch self {
            case .newest:
                return L.offerSortNewest()
            case .oldest:
                return L.offerSortOldest()
            }
        }
    }
}

#if DEBUG || DEVEL
struct OfferSortViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            OfferSortView(numberOfOffers: 13, sortingOption: .constant(.newest))
        }
        .previewDevice("iPhone 11")
        .background(Color.black)
    }
}
#endif
