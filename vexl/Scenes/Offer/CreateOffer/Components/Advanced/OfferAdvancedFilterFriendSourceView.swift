//
//  OfferAdvancedFilterFriendSource.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 24.05.2022.
//

import SwiftUI

typealias OfferAdvancedFriendSourceOption = OfferAdvancedFilterFriendSourceView.Option

struct OfferAdvancedFilterFriendSourceView: View {

    @Binding var selectedOptions: [Option]
    private let options: [Option] = [.contactList, .facebook]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Friend source")
                .textStyle(.paragraph)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Appearance.Colors.gray3)

            MultipleOptionPickerView(selectedOptions: $selectedOptions,
                                     options: options,
                                     content: { option in
                Text(option.title)
            }, action: nil)
        }
    }
}

extension OfferAdvancedFilterFriendSourceView {
    enum Option: String {
        case contactList
        case facebook

        var title: String {
            switch self {
            case .contactList:
                return "Contact list"
            case .facebook:
                return "Facebook"
            }
        }
    }
}

#if DEBUG || DEVEL
// swiftlint:disable type_name
struct OfferAdvancedFilterFriendSourceViewPreview: PreviewProvider {
    static var previews: some View {
        OfferAdvancedFilterFriendSourceView(
            selectedOptions: .constant([.contactList, .facebook])
        )
        .previewDevice("iPhone 11")
    }
}
#endif
