//
//  RegisterContacts+PortraitView.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import Foundation
import SwiftUI

extension RequestAccessContactsView {

    struct PortraitView: View {

        private let portraitSize = CGSize(width: 132, height: 132)
        private let avatarSize = CGSize(width: 66, height: 66)

        let name: String
        let image: UIImage?
        let color: Color
        let textColor: Color

        var body: some View {
            VStack {
                ZStack {
                    Color.white.opacity(0.12)

                    displayedImage
                }
                .frame(width: portraitSize.height, height: portraitSize.width, alignment: .center)
                .cornerRadius(portraitSize.height * 0.5)
                .padding(Appearance.GridGuide.point * 0.5)

                Text(name)
                    .textStyle(.h3)
                    .foregroundColor(textColor)
                    .padding(.bottom, Appearance.GridGuide.point)
            }
            .background(color)
            .cornerRadius(portraitSize.height * 0.5, corners: [.topLeft, .topRight])
            .cornerRadius(Appearance.GridGuide.point, corners: [.bottomLeft, .bottomRight])
        }

        @ViewBuilder private var displayedImage: some View {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(R.image.onboarding.emptyAvatar.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: avatarSize.width, height: avatarSize.height, alignment: .center)
            }
        }
    }

    struct RegisterPortraitsView: View {

        let name: String
        let avatar: UIImage
        let color: Color
        let textColor: Color

        var body: some View {
            ZStack {
                HStack {
                    PortraitView(name: "*****", image: nil, color: color, textColor: textColor)
                        .opacity(0.5)
                        .scaleEffect(0.75)

                    PortraitView(name: "*****", image: nil, color: color, textColor: textColor)
                        .opacity(0.5)
                        .scaleEffect(0.75)
                }

                PortraitView(name: name, image: avatar, color: color, textColor: textColor)
            }
        }
    }
}

struct RegisterContacts_PortraitViewPreview: PreviewProvider {
    static var previews: some View {
        RequestAccessContactsView.PortraitView(name: "Diego",
                                               image: nil,
                                               color: Appearance.Colors.green5,
                                               textColor: Appearance.Colors.green1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))

        RequestAccessContactsView.PortraitView(name: "Diego",
                                               image: R.image.onboarding.testAvatar(),
                                               color: Appearance.Colors.green5,
                                               textColor: Appearance.Colors.green1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))

        RequestAccessContactsView.RegisterPortraitsView(name: "Diego",
                                                        avatar: R.image.onboarding.testAvatar()!,
                                                        color: Appearance.Colors.green5,
                                                        textColor: Appearance.Colors.green1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
