//
//  LockForceUpdateView.swift
//  vexl
//
//  Created by Diego Espinoza on 23/09/22.
//

import SwiftUI

struct LockAppView: View {
    var viewModel: LockAppViewModel
    private var imageSize: CGSize {
        .init(width: UIScreen.main.width * 0.5, height: UIScreen.main.height * 0.25)
    }
    private var imagePadding: EdgeInsets {
        let vertical = UIScreen.main.height * 0.025
        let horizontal = UIScreen.main.width * 0.1
        return .init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }

    var body: some View {
        VStack(spacing: .zero) {
            card
                .padding(.horizontal, Appearance.GridGuide.point)
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            if viewModel.showAction {
                LargeSolidButton(title: viewModel.actionTitle,
                                 font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                 style: .main,
                                 isFullWidth: true,
                                 isEnabled: .constant(true),
                                 action: {
                    viewModel.send(action: .updateTap)
                })
                .padding(.horizontal, Appearance.GridGuide.point)
            }
        }
        .frame(maxHeight: .infinity)
        .background(Appearance.Colors.black1.edgesIgnoringSafeArea(.all))
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: .zero) {
            VStack {
                Image(viewModel.image)
                    .resizable()
                    .scaledToFit()
                    .padding(imagePadding)
                    .frame(size: imageSize, alignment: .center)
                    .overlay(maintenanceOverlay, alignment: .topTrailing)

                Text(viewModel.largeTitle.lowercased())
                    .textStyle(.largeTitle)
                    .foregroundColor(Appearance.Colors.primaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            Text(viewModel.title)
                .textStyle(.h3)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding(.bottom, Appearance.GridGuide.point)

            Text(viewModel.subtitle)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray3)
        }
        .padding(Appearance.GridGuide.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    private var maintenanceOverlay: some View {
        Group {
            if viewModel.showOverlay {
                Image(R.image.lockApp.maintenanceSleep.name)
            }
        }
    }
}

#if DEVEL || DEBUG

struct LockAppViewPreview: PreviewProvider {
    static var previews: some View {
        LockAppView(viewModel: .init(style: .update))
            .previewDevice("iPhone 14")

        LockAppView(viewModel: .init(style: .maintenance))
            .previewDevice("iPhone 14")
    }
}

#endif
