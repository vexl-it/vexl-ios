//
//  GroupsInputView.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import SwiftUI

struct GroupsInputView: View {
    @ObservedObject var viewModel: GroupsInputViewModel

    var body: some View {
        VStack {
            VStack(spacing: Appearance.GridGuide.padding) {
                Text(L.groupsEnterCodeDescription())
                    .textStyle(.h3)
                    .foregroundColor(Appearance.Colors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PlaceholderTextField(placeholder: L.groupsEnterCodeHint(), text: $viewModel.groupCode)
                    .textStyle(.paragraphMedium)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Appearance.Colors.primaryText)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Appearance.Colors.gray6)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)
                    .padding(.bottom, Appearance.GridGuide.largePadding2)
            }
            .padding(Appearance.GridGuide.padding)
            .background(Appearance.Colors.whiteText)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
            .padding([.horizontal], Appearance.GridGuide.point)
            .frame(maxHeight: .infinity, alignment: .top)

            HStack {
                if viewModel.fromDeeplink {
                    LargeSolidButton(title: L.generalClose(),
                                     font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                     style: .secondary,
                                     isFullWidth: true,
                                     isEnabled: .constant(true),
                                     action: {
                        viewModel.action.send(.dismissTap)
                    })
                }

                LargeSolidButton(title: L.continue(),
                                 font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                 style: .main,
                                 isFullWidth: true,
                                 isEnabled: .constant(viewModel.isCodeValid),
                                 action: {
                    viewModel.action.send(.continueTap)
                })
            }
                .padding([.horizontal, .bottom], Appearance.GridGuide.point)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL

struct GroupsInputViewPreview: PreviewProvider {
    static var previews: some View {
        GroupsInputView(viewModel: .init(code: "123456", fromDeeplink: false))
            .previewDevice("iPhone 11")
    }
}

#endif
