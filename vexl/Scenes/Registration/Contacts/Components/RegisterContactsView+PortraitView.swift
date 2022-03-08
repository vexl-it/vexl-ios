//
//  RegisterContacts+PortraitView.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import Foundation
import SwiftUI

extension RegisterContactsView {

    struct PortraitView: View {

        let name: String
        let image: UIImage?

        var body: some View {
            VStack {
                ZStack {
                    Color.white.opacity(0.12)

                    displayedImage
                }
                .frame(width: 132, height: 132, alignment: .center)
                .cornerRadius(132 * 0.5)
                .padding(Appearance.GridGuide.point * 0.5)

                Text(name)
                    .textStyle(.h3)
                    .foregroundColor(Appearance.Colors.green5)
                    .padding(.bottom, Appearance.GridGuide.point)
            }
            .background(Appearance.Colors.green1)
            .cornerRadius(132 * 0.5, corners: [.topLeft, .topRight])
            .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
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
                    .frame(width: 66, height: 66, alignment: .center)
            }
        }
    }

    struct RegisterPortraitsView: View {

        let name: String
        let avatar: UIImage

        var body: some View {
            ZStack {
                HStack {
                    RegisterContactsView.PortraitView(name: "*****", image: nil)
                        .opacity(0.5)
                        .scaleEffect(0.75)

                    RegisterContactsView.PortraitView(name: "*****", image: nil)
                        .opacity(0.5)
                        .scaleEffect(0.75)
                }

                RegisterContactsView.PortraitView(name: name,
                                                  image: avatar)
            }
        }
    }
}

struct RegisterContactsViewPortraitViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterContactsView.PortraitView(name: "Diego", image: nil)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))

        RegisterContactsView.PortraitView(name: "Diego", image: R.image.onboarding.testAvatar())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))

        RegisterContactsView.RegisterPortraitsView(name: "Diego",
                                                   avatar: R.image.onboarding.testAvatar()!)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
