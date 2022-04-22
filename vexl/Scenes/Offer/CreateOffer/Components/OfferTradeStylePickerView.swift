//
//  OfferTradeStylePickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct OfferTradeStylePickerView: View {

    enum Option {
        case online
        case personal

        var title: String {
            switch self {
            case .online:
                return "Online ok"
            case .personal:
                return "Only in person"
            }
        }
    }

    @State private var selectedOption = Option.online
    var options = [Option.online, .personal]

    var body: some View {
        SegmentedPickerView(selectedOption: $selectedOption,
                            options: options) { option in
            Text(option.title)
                .foregroundColor(Appearance.Colors.green5)
        }
    }
}
