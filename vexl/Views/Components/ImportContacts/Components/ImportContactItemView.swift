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
                .cornerRadius(Appearance.GridGuide.buttonCorner)

            Spacer()

            VStack(alignment: .leading, spacing: Appearance.GridGuide.tinyPadding) {
                Text(item.name)
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.primaryText)

                if !item.phone.isEmpty {
                    Text(item.formattedPhone)
                        .textStyle(.descriptionBold)
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
        let placeholder: String = R.image.avatars.defaultAvatar1.name
        if let avatarURL = item.avatarURL, let url = URL(string: avatarURL) {
            FetchImage(url: url, placeholder: placeholder)
        } else {
            Image(data: item.avatar, placeholder: placeholder)
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
                    Appearance.Colors.yellow100
                        .cornerRadius(Appearance.GridGuide.buttonCorner)
                    Text(Image(systemName: "checkmark"))
                        .fontWeight(.bold)
                        .foregroundColor(Appearance.Colors.black1)
                }
            } else {
                Appearance.Colors.whiteText
                    .cornerRadius(Appearance.GridGuide.buttonCorner)
            }
        }
        .makeCorneredBorder(color: isSelected ? Appearance.Colors.yellow100 : Appearance.Colors.gray4,
                            borderWidth: 1,
                            cornerRadius: Appearance.GridGuide.buttonCorner)
    }
}

#if DEBUG || DEVEL
struct RegisterContacts_ContactItemViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ImportContactItemView(item: ContactInformation.stub()[0], onSelection: { _ in })
            ImportContactItemView(item: ContactInformation.stub()[1], onSelection: { _ in })
        }
    }
}
#endif
