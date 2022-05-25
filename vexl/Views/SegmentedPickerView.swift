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
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Appearance.Colors.gray2)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Appearance.Colors.whiteText),
                                                                        .font: Appearance.TextStyle.paragraph.font], for: .selected)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Appearance.Colors.gray4),
                                                                        .font: Appearance.TextStyle.paragraph.font], for: .normal)
            }
        }
    }
}
