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
    let content: (Option) -> Content
    let action: (Option) -> Void

    var body: some View {
        HStack {
            ForEach(options, id: \.self) { option in
                Button {
                    selectedOption = option
                    action(option)
                } label: {
                    content(option)
                }
                .padding()
                .foregroundColor(option == selectedOption ? Appearance.Colors.green5 : Appearance.Colors.gray3)
                .background(option == selectedOption ? Appearance.Colors.gray2 : Appearance.Colors.gray1)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
                .animation(.easeInOut(duration: 0.25))
            }
        }
    }
}

#if DEBUG || DEVEL
struct SingleOptionPickerViewPreview: PreviewProvider {

    enum Option: String {
        case test, test1, test2
    }

    static var previews: some View {
        SingleOptionPickerView(selectedOption: .constant(.test),
                               options: [Option.test, .test1, .test2],
                               content: { option in
            Text(option.rawValue)
                .foregroundColor(Appearance.Colors.green5)
        },
                               action: { _ in
        })
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
