//
//  OfferStatusView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct OfferStatusView: View {

    let pauseAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        HStack {
            HStack {
                Circle()
                    .foregroundColor(Appearance.Colors.green5)
                    .frame(size: Appearance.GridGuide.smallIconSize)

                Text(L.offerCreateStatusActive())
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.green5)
            }

            Spacer()

            HStack(spacing: Appearance.GridGuide.padding) {

                OfferButton(title: L.offerCreateStatusPause(),
                            iconName: "pause") {
                    pauseAction()
                }

                OfferButton(title: L.offerCreateStatusDelete(),
                            iconName: "trash.fill") {
                    deleteAction()
                }
            }
        }
    }

    private struct OfferButton: View {
        let title: String
        let iconName: String
        let action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                HStack {
                    Image(systemName: iconName)

                    Text(title)
                }
                .foregroundColor(Appearance.Colors.gray3)
            }
            .padding(Appearance.GridGuide.smallPadding)
            .makeCorneredBorder(color: Appearance.Colors.gray1,
                                borderWidth: 1,
                                cornerRadius: Appearance.GridGuide.buttonCorner)
        }
    }
}
