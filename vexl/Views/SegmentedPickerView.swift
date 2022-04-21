//
//  SegmentedPickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct SegmentedPickerView<Option: Hashable, Content: View>: View {

    @Binding var selectedOption: Option
    var options: [Option]
    var label: (Option) -> Content

    var body: some View {
        VStack {
            Picker("", selection: $selectedOption) {
                ForEach(options, id: \.self) {
                    label($0)
                }
            }
            .padding(Appearance.GridGuide.point)
            .pickerStyle(.segmented)
            .background(Appearance.Colors.gray1)
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = R.color.gray2()
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: R.color.green5()!,
                                                                        .font: Appearance.TextStyle.paragraph.font], for: .selected)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: R.color.gray3()!,
                                                                        .font: Appearance.TextStyle.paragraph.font], for: .normal)
            }
        }
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}
