//
//  MultipleOptionPickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import SwiftUI

struct MultipleOptionPickerView<Option: Hashable, Content: View>: View {

    @Binding var selectedOptions: [Option]
    let options: [Option]
    @ViewBuilder let content: (Option) -> Content
    let action: ((Option, Bool) -> Void)?

    var body: some View {
        HStack {
            ForEach(options, id: \.self) { option in
                OptionPickerItemView(isSelected: selectedOptions.contains(option),
                                     content: {
                    content(option)
                },
                                     action: {
                    let index = selectedOptions.firstIndex(of: option)
                    if let index = index {
                        selectedOptions.remove(at: index)
                    } else {
                        selectedOptions.append(option)
                    }
                    action?(option, index != nil)
                })
            }
        }
    }
}
