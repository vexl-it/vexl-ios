//
//  BuySellFeedDetailFooterView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

struct BuySellFeedFooterView: View {

    enum ContactType {
        case phone
        case facebook
    }

    let contactType: ContactType
    let isRequested: Bool
    let location: String
    let action: () -> Void

    var body: some View {
        HStack {
            if contactType == .facebook {
                Image(R.image.marketplace.facebookCircle.name)
                    .resizable()
                    .frame(size: isRequested ? Appearance.GridGuide.iconSize : Appearance.GridGuide.mediumIconSize)
            }

            VStack {
                Text(contactType == .facebook ? L.marketplaceFacebookFriend() : L.marketplacePhoneContact())
                    .textStyle(isRequested ? .paragraph : .paragraphBold)
                    .foregroundColor(isRequested ? Appearance.Colors.gray2 : Appearance.Colors.gray1)

                if !isRequested {
                    Text(location)
                        .textStyle(.paragraph)
                        .foregroundColor(Appearance.Colors.gray2)
                }
            }

            Spacer()

            if isRequested {
                HStack {
                    Image(systemName: "checkmark")
                        .resizable()
                        .foregroundColor(Appearance.Colors.green4)
                        .frame(size: Appearance.GridGuide.smallIconSize)

                    Text(L.offerRequested())
                        .textStyle(.description)
                        .foregroundColor(Appearance.Colors.green4)
                }
            } else {
                Button {
                    action()
                } label: {
                    HStack {
                        Image(R.image.onboarding.eye.name)

                        Text(L.offerRequest())
                            .textStyle(.description)
                            .foregroundColor(Appearance.Colors.primaryText)
                    }
                    .padding(.horizontal, Appearance.GridGuide.padding)
                }
                .frame(height: Appearance.GridGuide.baseHeight)
                .background(Appearance.Colors.purple5)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
            }
        }
    }
}

#if DEBUG || DEVEL
struct BuySellFeedFooterViewPreview: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            BuySellFeedFooterView(contactType: .phone,
                                  isRequested: true,
                                  location: "Prague",
                                  action: {})
                .previewDevice("iPhone 11")
            BuySellFeedFooterView(contactType: .phone,
                                  isRequested: false,
                                  location: "Prague",
                                  action: {})
                .previewDevice("iPhone 11")
            BuySellFeedFooterView(contactType: .facebook,
                                  isRequested: true,
                                  location: "Prague",
                                  action: {})
                .previewDevice("iPhone 11")
            BuySellFeedFooterView(contactType: .facebook,
                                  isRequested: false,
                                  location: "Prague",
                                  action: {})
                .previewDevice("iPhone 11")
        }
        .padding()
    }
}
#endif
