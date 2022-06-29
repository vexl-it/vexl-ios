//
//  ChatFilterView.swift
//  vexl
//
//  Created by Diego Espinoza on 25/05/22.
//

import SwiftUI

struct InboxFilterView: View {

    enum Option: CaseIterable {
        case all
        case buy
        case sell

        var title: String {
            switch self {
            case .all:
                return L.chatFilterAll()
            case .buy:
                return L.chatFilterBuy()
            case .sell:
                return L.chatFilterSell()
            }
        }
    }

    @Binding var selectedOption: Option
    var action: (Option) -> Void

    var body: some View {
        SingleOptionPickerView(selectedOption: $selectedOption,
                               options: Option.allCases,
                               content: { option in
            Text(option.title)
                .padding(.horizontal, Appearance.GridGuide.tinyPadding)
        },
                               action: { option in
            action(option)
        })
            .padding(.horizontal, Appearance.GridGuide.padding)
    }
}