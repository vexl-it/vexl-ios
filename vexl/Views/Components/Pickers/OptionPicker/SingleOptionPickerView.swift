//
//  SinglePickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/04/22.
//

import SwiftUI

struct SingleOptionPickerView<Option: Hashable, Content: View>: View {

    @Binding var selectedOption: Option
    let options: [Option]
    @ViewBuilder let content: (Option) -> Content
    let action: ((Option) -> Void)?

    var body: some View {
        HStack {
            ForEach(options, id: \.self) { option in
                OptionPickerItemView(isSelected: option == selectedOption,
                                     content: {
                    content(option)
                },
                                     action: {
                    selectedOption = option
                    action?(option)
                })
            }
        }
    }
}
