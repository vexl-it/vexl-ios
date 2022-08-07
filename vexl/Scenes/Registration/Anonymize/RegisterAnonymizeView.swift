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

    private let defaultImageSize: CGSize = Appearance.GridGuide.avatarSize

    var body: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding1) {
            Text("This is your identity")
                .foregroundColor(Appearance.Colors.whiteText)
                .textStyle(.paragraphSemibold)

            Image(data: viewModel.avatar, placeholder: "")
                .resizable()
                .scaledToFill()
                .frame(size: defaultImageSize)
                .clipped()
                .cornerRadius(Appearance.GridGuide.requestAvatarCorner)

            Text(viewModel.username)
                .foregroundColor(Appearance.Colors.whiteText)
                .textStyle(.h2)
                .frame(maxWidth: .infinity)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, Appearance.GridGuide.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
