//
//  OfferHeaderView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct OfferHeaderView: View {

    let title: String
    let dismissAction: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(title)
                    .textStyle(.largeTitle)
                    .foregroundColor(Appearance.Colors.whiteText)

                Spacer()

                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.white)
                        .padding(Appearance.GridGuide.point)
                        .background(Appearance.Colors.gray1)
                        .cornerRadius(Appearance.GridGuide.point)
                }
                .padding(.bottom, Appearance.GridGuide.point)
            }
            .padding(.horizontal, Appearance.GridGuide.padding)

            Rectangle()
                .foregroundColor(Color.white)
                .frame(height: 3)
                .padding(.horizontal, Appearance.GridGuide.point)
        }
    }
}
