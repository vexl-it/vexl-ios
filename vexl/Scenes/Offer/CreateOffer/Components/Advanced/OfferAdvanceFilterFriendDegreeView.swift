//
//  OfferAdvancedFriendDegreeView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import SwiftUI

typealias OfferAdvancedFriendDegreeOption = OfferAdvanceFilterFriendDegreeView.Option

struct OfferAdvanceFilterFriendDegreeView: View {

    @Binding var selectedOption: Option
    private let options: [Option] = [.firstDegree, .secondDegree]

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text(L.offerCreateAdvancedFriendLevelTitle())
                    .textStyle(.paragraph)

                Text(L.offerCreateAdvancedFriendDescription())
                    .textStyle(.micro)
            }
            .foregroundColor(Appearance.Colors.gray3)

            SingleOptionPickerView(selectedOption: $selectedOption,
                                   options: options,
                                   content: { option in
                Image(option.imageName)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .offset(x: -10, y: -10)
                    )
            }, action: nil)
        }
    }
}

extension OfferAdvanceFilterFriendDegreeView {
    enum Option: String {
        case firstDegree = "FIRST_DEGREE"
        case secondDegree = "SECOND_DEGREE"

        var degree: Int {
            switch self {
            case .firstDegree:
                return 1
            case .secondDegree:
                return 2
            }
        }

        var imageName: String {
            switch self {
            case .firstDegree:
                return R.image.offer.firstDegree.name
            case .secondDegree:
                return R.image.offer.secondDegree.name
            }
        }
    }
}

#if DEBUG || DEVEL
// swiftlint:disable type_name
struct OfferAdvanceFilterFriendDegreeViewPreview: PreviewProvider {
    static var previews: some View {
        OfferAdvanceFilterFriendDegreeView(
            selectedOption: .constant(.firstDegree)
        )
        .previewDevice("iPhone 11")
    }
}
#endif
