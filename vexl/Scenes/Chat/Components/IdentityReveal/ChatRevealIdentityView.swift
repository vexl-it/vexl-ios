//
//  ChatIdentityRequestView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatRevealIdentityView: View {

    let image: UIImage?
    let isRequest: Bool
    let revealAction: (() -> Void)?

    private var title: String {
        isRequest ? L.chatMessageIdentityRevealRequestSent() : L.chatMessageIdentityRevealRequest()
    }

    private var subtitle: String {
        isRequest ? L.chatMessageIdentityRevealPending() : L.chatMessageIdentityRevealPendingTap()
    }

    var body: some View {
        VStack(spacing: .zero) {

            ContactAvatarView(image: image,
                              size: Appearance.GridGuide.chatRequestAvatarSize)
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            HStack {

                HLine(color: Appearance.Colors.whiteOpaque,
                      height: 1)
                    .frame(maxWidth: .infinity)

                Text(L.chatMessageIdentityRevealHeader())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Appearance.Colors.gray3)
                    .textStyle(.description)
                    .padding(.bottom, Appearance.GridGuide.tinyPadding)
                    .frame(maxWidth: .infinity)

                HLine(color: Appearance.Colors.whiteOpaque,
                      height: 1)
                    .frame(maxWidth: .infinity)
            }

            Text(L.chatMessageIdentityRevealSubheader())
                .foregroundColor(Appearance.Colors.whiteText)
                .textStyle(.titleSmallSemiBold)
                .padding(.bottom, Appearance.GridGuide.mediumPadding1)

            HStack {
                Image(R.image.marketplace.defaultAvatar.name)

                VStack(alignment: .leading) {
                    Text(title)
                        .textStyle(.paragraphSmallSemiBold)

                    Text(subtitle)
                        .textStyle(.description)
                        .foregroundColor(Appearance.Colors.gray3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isRequest {
                    requestActionButton
                } else {
                    responseActionButton
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Appearance.Colors.whiteText)
        }
    }

    private var requestActionButton: some View {
        Text(L.chatMessageIdentityRevealPendingOk())
            .textStyle(.paragraphSmall)
            .foregroundColor(Appearance.Colors.gray2)
            .padding(Appearance.GridGuide.point)
            .background(Appearance.Colors.gray6)
            .cornerRadius(Appearance.GridGuide.point)
    }

    private var responseActionButton: some View {
        Button {
            revealAction?()
        } label: {
            Image(systemName: "chevron.right")
                .foregroundColor(Appearance.Colors.primaryText)
        }
        .padding(Appearance.GridGuide.point)
        .background(Appearance.Colors.yellow100)
        .cornerRadius(Appearance.GridGuide.point)
    }
}

#if DEBUG || DEVEL

struct ChatIdentityRequestViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatRevealIdentityView(image: R.image.onboarding.testAvatar()!,
                                   isRequest: true,
                                   revealAction: nil)

            ChatRevealIdentityView(image: nil,
                                   isRequest: false,
                                   revealAction: nil)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
