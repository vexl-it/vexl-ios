//
//  PageControl.swift
//  vexl
//
//  Created by Diego Espinoza on 5/08/22.
//

import SwiftUI

struct PageControl: View {

    let numberOfPages: Int
    let currentIndex: Int

    var body: some View {
        HStack {
            ForEach(0 ..< numberOfPages, id: \.self) { index in
                HLine(color: currentIndex >= index ? Appearance.Colors.black1 : Appearance.Colors.gray4,
                      height: Appearance.GridGuide.tinyPadding)
                    .frame(height: Appearance.GridGuide.tinyPadding)
                    .cornerRadius(Appearance.GridGuide.tinyPadding * 0.5)
                    .transition(.opacity)
            }
        }
    }
}
