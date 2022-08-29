//
//  LargeButton.swift
//  vexl
//
//  Created by Diego Espinoza on 16/02/22.
//

import SwiftUI

struct LabelButton<Content: View>: View {
    @Binding var isEnabled: Bool
    let backgroundColor: Color
    var verticalPadding: CGFloat = Appearance.GridGuide.padding
    let content: () -> Content
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            content()
                .frame(maxWidth: .infinity)
                .padding(.vertical, verticalPadding)
        }
        .background(isEnabled ? backgroundColor : Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.point)
        .contentShape(RoundedRectangle(cornerRadius: Appearance.GridGuide.point))
        .disabled(!isEnabled)
    }
}

struct LabelButton_Previews: PreviewProvider {
    static var previews: some View {
        LabelButton(isEnabled: .constant(true),
                    backgroundColor: Appearance.Colors.pink20,
                    content: {
                        HStack(alignment: .center) {
                            Image(systemName: "plus")
                            
                            Text("Lore impsum")
                                .textStyle(.descriptionBold)
                        }
                        .foregroundColor(Appearance.Colors.pink100)
                    },
                    action: { })
    }
}
