//
//  RegisterAnonymizeView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 07.08.2022.
//

import Foundation
import SwiftUI
import Cleevio

struct RegisterAnonymizeView: View {
    @ObservedObject var viewModel: RegisterAnonymizeViewModel

    private let anonymizeSize: CGSize = .init(width: 128, height: 128)

    var body: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding1) {
            Spacer()

            Text(viewModel.identityText)
                .foregroundColor(Appearance.Colors.whiteText)
                .textStyle(.paragraphSemibold)

            avatarView

            Text(viewModel.username)
                .foregroundColor(Appearance.Colors.whiteText)
                .textStyle(.h2)
                .frame(maxWidth: .infinity)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, Appearance.GridGuide.padding)

            Spacer()

            HStack {
                if viewModel.showSubtitleIcon {
                    Image(R.image.onboarding.eye.name)
                }

                Text(viewModel.subtitle)
                    .foregroundColor(Appearance.Colors.gray4)
                    .textStyle(.paragraphSmall)
            }

            LargeSolidButton(title: viewModel.buttonTitle,
                             font: Appearance.TextStyle.titleSmallBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                print("")
            })
                .padding(.horizontal, Appearance.GridGuide.point)
                .padding(.bottom, Appearance.GridGuide.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var avatarView: some View {
        ZStack(alignment: .topTrailing) {
            Image(data: viewModel.avatar, placeholder: R.image.profile.avatar.name)
                .resizable()
                .scaledToFill()
                .frame(size: anonymizeSize)
                .clipped()
                .cornerRadius(32)

            Button(action: { print("sup") }, label: {
                Circle()
                    .strokeBorder(.black, lineWidth: 4)
                    .background(Circle().fill(Appearance.Colors.yellow100))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(R.image.onboarding.shuffle.name)
                    )
                    .offset(x: 5, y: -5)
            })
        }
    }
}

struct RegisterAnonymizeViewPreview: PreviewProvider {
    static var previews: some View {
        let avatar = R.image.onboarding.testAvatar()?.jpegData(compressionQuality: 1)
        let input = AnonymizeInput(
            username: "Daniel Fernandez",
            avatar: avatar
        )
        RegisterAnonymizeView(
            viewModel: .init(input: input)
        )
        .background(Color.black.ignoresSafeArea())
    }
}
