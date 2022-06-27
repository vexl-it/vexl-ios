//
//  CheckBox.swift
//  vexl
//
//  Created by Adam Salih on 23.06.2022.
//

import SwiftUI

struct RadioButton: View {
    var isChecked: Bool

    var checkedColor: Color = Appearance.Colors.yellow100
    var uncheckedColor: Color = Appearance.Colors.gray4
    var size: Double = 24

    private var checkSize: Double { size * 0.667 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(isChecked ? checkedColor : uncheckedColor, lineWidth: 2)
            if isChecked {
                Circle()
                    .foregroundColor(checkedColor)
                    .frame(width: checkSize, height: checkSize)
            }
        }
        .frame(width: size, height: size)
    }
}

struct CheckBox_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            RadioButton(isChecked: true)
            RadioButton(isChecked: false)
        }
    }
}
