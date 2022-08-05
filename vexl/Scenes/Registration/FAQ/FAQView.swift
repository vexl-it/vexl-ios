//
//  FAQView.swift
//  vexl
//
//  Created by Diego Espinoza on 4/08/22.
//

import SwiftUI

struct FAQView: View {

    @ObservedObject var viewModel: FAQViewModel

    var body: some View {
        VStack(spacing: .zero) {

            card
                .padding(.horizontal, Appearance.GridGuide.point)
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            HStack {
                LargeSolidButton(title: viewModel.backButtonTitle,
                                 font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                 style: .secondary,
                                 isFullWidth: true,
                                 isEnabled: .constant(true),
                                 action: {
                    withAnimation {
                        viewModel.action.send(.backTap)
                    }
                })

                LargeSolidButton(title: viewModel.nextButtonTitle,
                                 font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                 style: .main,
                                 isFullWidth: true,
                                 isEnabled: .constant(true),
                                 action: {
                    withAnimation {
                        viewModel.action.send(.nextTap)
                    }
                })
            }
            .padding(.horizontal, Appearance.GridGuide.point)
        }
        .frame(maxHeight: .infinity)
        .background(Appearance.Colors.black1.edgesIgnoringSafeArea(.all))
    }

    private var card: some View {
        VStack {
            PageControl(numberOfPages: viewModel.content.count,
                        currentIndex: viewModel.currentIndex)
                .padding([.horizontal, .top], Appearance.GridGuide.smallPadding)

            HStack {
                Text(L.faqTitle())
                    .textStyle(.paragraphSemibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                CloseButton(textColor: Appearance.Colors.black1,
                            backgroundColor: Appearance.Colors.gray5) {
                    viewModel.route.send(.continueTapped)
                }
            }
            .padding(Appearance.GridGuide.padding)

            VStack(alignment: .leading, spacing: .zero) {
                Text(viewModel.title)
                    .textStyle(.h3)
                    .foregroundColor(Appearance.Colors.primaryText)
                    .padding(.bottom, Appearance.GridGuide.point)
                    .transition(.opacity.animation(.easeIn))
                    .id(viewModel.currentIndex)

                AttributedText(attributedText: viewModel.description)
                    .transition(.opacity.animation(.easeIn))
                    .id(viewModel.currentIndex)
            }
            .padding(Appearance.GridGuide.padding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

#if DEVEL || DEBUG

struct FAQViewPreview: PreviewProvider {
    static var previews: some View {
        FAQView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}

#endif
