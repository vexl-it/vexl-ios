//
//  OfferStatusView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct OfferStatusView: View {

    let isActive: Bool
    let showDeleteButton: Bool
    let pauseAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        HStack {
            HStack {
                Circle()
                    .foregroundColor(isActive ? Appearance.Colors.green100 : Appearance.Colors.red100)
                    .frame(size: Appearance.GridGuide.smallIconSize)

                Text(isActive ? L.offerCreateStatusActive() : L.offerCreateStatusInactive())
                    .textStyle(.paragraph)
                    .foregroundColor(isActive ? Appearance.Colors.green100 : Appearance.Colors.yellow100)
            }

            Spacer()

            HStack(spacing: Appearance.GridGuide.padding) {
                OfferButton(title: isActive ? L.offerCreateStatusPause() : L.offerCreateStatusActivate(),
                            iconName: isActive ? "pause" : "play") {
                    pauseAction()
                }

                if showDeleteButton {
                    OfferButton(title: L.offerCreateStatusDelete(),
                                iconName: "trash.fill") {
                        deleteAction()
                    }
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
                .foregroundColor(Appearance.Colors.gray4)
            }
            .padding(Appearance.GridGuide.smallPadding)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

#if DEBUG || DEVEL
struct OfferStatusViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            OfferStatusView(isActive: true,
                            showDeleteButton: true,
                            pauseAction: {},
                            deleteAction: {})
                .previewDevice("iPhone 11")
                .background(Color.black)

            OfferStatusView(isActive: false,
                            showDeleteButton: false,
                            pauseAction: {},
                            deleteAction: {})
                .previewDevice("iPhone 11")
                .background(Color.black)
        }
    }
}
#endif
