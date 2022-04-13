//
//  RegisterContactsView+ContactItem.swift
//  vexl
//
//  Created by Diego Espinoza on 14/03/22.
//

import Foundation
import SwiftUI
import Kingfisher

struct ImportContactItemView: View {

    private let imageSize = CGSize(width: 48, height: 48)
    private let checkSize = CGSize(width: 38, height: 38)

    let item: ContactInformation
    let onSelection: (Bool) -> Void

    var body: some View {
        HStack {
            avatarImage
                .frame(size: imageSize)
                .cornerRadius(imageSize.height * 0.5, corners: .allCorners)

            Spacer()

            VStack(alignment: .leading, spacing: Appearance.GridGuide.smallPadding) {
                Text(item.name)
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.primaryText)

                if !item.phone.isEmpty {
                    Text(item.phone)
                        .textStyle(.descriptionSemibold)
                        .foregroundColor(Appearance.Colors.gray3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Appearance.GridGuide.point)

            Spacer()

            selectionView
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
        .padding(.bottom, Appearance.GridGuide.point)
    }

    @ViewBuilder private var avatarImage: some View {
        if let avatarURL = item.avatarURL, let url = URL(string: avatarURL) {
            KFImage(url)
                .resizable()
        } else {
            Image(data: item.avatar, placeholder: R.image.onboarding.emptyAvatar.name)
                .resizable()
        }
    }

    private var selectionView: some View {
        ImportContactSelectionView(isSelected: item.isSelected,
                                   action: {
            onSelection(!item.isSelected)
        })
            .frame(size: checkSize)
    }
}

private struct ImportContactSelectionView: View {

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

struct RegisterContacts_ContactItemViewPreview: PreviewProvider {
    static var previews: some View {
        ImportContactItemView(item: ContactInformation.stub().first!, onSelection: { _ in })
    }
}
