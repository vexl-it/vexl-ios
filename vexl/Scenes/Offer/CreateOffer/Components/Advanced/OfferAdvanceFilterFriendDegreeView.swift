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
            HStack {
                Text(L.offerCreateAdvancedFriendLevelTitle())
                    .textStyle(.paragraph)

                Spacer()

                Image(systemName: "arrow.clockwise")
            }
            .foregroundColor(Appearance.Colors.gray3)

            SingleOptionPickerView(selectedOption: $selectedOption,
                                   options: options,
                                   content: { option in
                Text(option.title)
                    .frame(maxWidth: .infinity)
            },
                                   action: nil)
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

        var title: String {
            switch self {
            case .firstDegree:
                return L.offerCreateAdvancedFriendLevelFirst()
            case .secondDegree:
                return L.offerCreateAdvancedFriendLevelSecond()
            }
        }
    }
}
