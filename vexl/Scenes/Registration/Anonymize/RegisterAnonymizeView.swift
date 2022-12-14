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

    @State private var size: CGSize = .zero
    @State private var animationOffset: CGFloat = .zero

    enum UIProperties {
        static let anonymizeSize: CGSize = .init(width: 128, height: 128)
        static let shuffleButtonSize: CGSize = .init(width: cornerRadius, height: cornerRadius)
        static let cornerRadius: CGFloat = 32
    }

    var body: some View {
        ZStack {
            content

            if viewModel.showAnimationOverlay {
                animationOverlay
                    .offset(x: size.width)
                    .offset(x: -animationOffset)
                    .onAppear {
                        animationOffset = size.width * 2
                    }
                    .onDisappear {
                        animationOffset = .zero
                    }
                    .animation(.easeInOut(duration: RegisterAnonymizeViewModel.animationDuration), value: animationOffset)
            }
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .readSize(onChange: { size = $0 })
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var content: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding1) {
            Spacer()

            userContent

            Spacer()

            HStack {
                if viewModel.showSubtitleIcon {
                    Image(R.image.onboarding.eye.name)
                }

                Text(viewModel.subtitle)
                    .foregroundColor(Appearance.Colors.gray4)
                    .textStyle(.paragraphSmall)
                    .multilineTextAlignment(.center)
            }

            LargeSolidButton(title: viewModel.buttonTitle,
                             font: Appearance.TextStyle.titleSmallBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                viewModel.send(
                    action: viewModel.currentState == .identity ? .anonymize : .createUser
                )
            })
            .padding(.bottom, Appearance.GridGuide.padding)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }

    private var userContent: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding1) {
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
        }
    }

    private var avatarView: some View {
        ZStack(alignment: .topTrailing) {
            if viewModel.currentState == .anonymized {
                RandomAvatarView(name: viewModel.anonymizedAvatar, contentMode: .scaleToFill)
                    .frame(size: UIProperties.anonymizeSize)
                    .clipped()
                    .cornerRadius(UIProperties.cornerRadius)

                Button(action: { viewModel.send(action: .anonymize) }, label: {
                    Circle()
                        .strokeBorder(.black, lineWidth: 4)
                        .background(Circle().fill(Appearance.Colors.yellow100))
                        .frame(size: UIProperties.shuffleButtonSize)
                        .overlay(
                            Image(R.image.onboarding.shuffle.name)
                        )
                        .offset(x: 5, y: -5)
                })
            } else {
                Image(data: viewModel.avatar, placeholder: R.image.profile.avatar.name)
                    .resizable()
                    .scaledToFill()
                    .frame(size: UIProperties.anonymizeSize)
                    .clipped()
                    .cornerRadius(UIProperties.cornerRadius)
            }
        }
    }

    private var animationOverlay: some View {
        Appearance.Colors.yellow100
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

extension RegisterAnonymizeView {
    private struct RandomAvatarView: UIViewRepresentable {
        var name: String
        var contentMode: UIView.ContentMode = .scaleAspectFit

        func makeUIView(context: Context) -> UIImageView {
            let imageView = UIImageView()
            imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
            return imageView
        }

        func updateUIView(_ uiView: UIImageView, context: Context) {
            uiView.contentMode = contentMode
            if let image = UIImage(named: name) {
                uiView.image = image
            }
        }
    }
}

struct RegisterAnonymizeViewPreview: PreviewProvider {
    static var identityViewModel: RegisterAnonymizeViewModel {
        let avatar = R.image.onboarding.testAvatar()?.jpegData(compressionQuality: 1)
        let input = AnonymizeInput(
            username: "Daniel Fernandez",
            avatar: avatar
        )
        return RegisterAnonymizeViewModel(input: input)
    }

    static var anonymizeViewModel: RegisterAnonymizeViewModel {
        let avatar = R.image.onboarding.testAvatar()?.jpegData(compressionQuality: 1)
        let input = AnonymizeInput(
            username: "Daniel Fernandez",
            avatar: avatar
        )
        let viewModel = RegisterAnonymizeViewModel(input: input)
        viewModel.currentState = .anonymized
        return viewModel
    }

    static var previews: some View {
        RegisterAnonymizeView(
            viewModel: identityViewModel
        )
        .background(Color.black.ignoresSafeArea())

        RegisterAnonymizeView(
            viewModel: anonymizeViewModel
        )
        .background(Color.black.ignoresSafeArea())
    }
}
