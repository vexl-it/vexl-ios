//
//  RegisterContactsView+ContactItem.swift
//  vexl
//
//  Created by Diego Espinoza on 14/03/22.
//

import Foundation
import SwiftUI

extension RegisterContactsView {

    private struct ContactItemSelectionView: View {

        var isSelected: Bool
        var action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                if isSelected {
                    ZStack {
                        Appearance.Colors.green5
                            .cornerRadius(Appearance.GridGuide.buttonCorner)
                        Image(systemName: "checkmark")
                            .foregroundColor(Appearance.Colors.green1)
                    }
                } else {
                    Appearance.Colors.gray4
                        .cornerRadius(Appearance.GridGuide.buttonCorner)
                }
            }
        }
    }

    struct ContactItemView: View {

        private let imageSize = CGSize(width: 48, height: 48)
        private let checkSize = CGSize(width: 38, height: 38)

        let item: RegisterContactsViewModel.ContactItem
        let onSelection: (Bool) -> Void

        var body: some View {
            HStack {
                Image(R.image.onboarding.emptyAvatar.name)
                    .resizable()
                    .frame(size: imageSize)

                Spacer()

                VStack(alignment: .leading, spacing: Appearance.GridGuide.smallPadding) {
                    Text(item.name)
                        .textStyle(.paragraph)
                        .foregroundColor(Appearance.Colors.primaryText)

                    Text(item.phone)
                        .textStyle(.descriptionSemibold)
                        .foregroundColor(Appearance.Colors.gray3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Appearance.GridGuide.point)

                Spacer()

                selectionView
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .padding(.bottom, Appearance.GridGuide.point)
        }

        private var selectionView: some View {
            RegisterContactsView.ContactItemSelectionView(isSelected: item.isSelected, action: {
                onSelection(!item.isSelected)
            })
                .frame(size: checkSize)
        }
    }
}

struct RegisterContacts_ContactItemViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterContactsView.ContactItemView(item: RegisterContactsViewModel.ContactItem.stub().first!, onSelection: { _ in })
    }
}
