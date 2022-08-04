//
//  OfferAdvancedFriendDegreeView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import SwiftUI

struct OfferAdvanceFilterFriendDegreeView: View {

    @Binding var selectedOption: OfferFriendDegree
    private let options: [OfferFriendDegree] = [.firstDegree, .secondDegree]

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
                if let option = option {
                    Image(option.imageName)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Image(systemName: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .offset(x: -10, y: -10)
                                .opacity(selectedOption == option ? 1 : 0)
                        )
                }
            }, action: nil)
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
