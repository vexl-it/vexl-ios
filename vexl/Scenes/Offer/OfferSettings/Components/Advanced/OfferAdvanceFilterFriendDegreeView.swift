//
//  OfferAdvancedFriendDegreeView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import SwiftUI

struct OfferAdvanceFilterFriendDegreeView: View {
    var avatar: Data?
    @Binding var selectedOption: OfferFriendDegree

    private let options: [OfferFriendDegree] = [.firstDegree, .secondDegree]
    @State private var imageHeight: CGFloat = .zero

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text(L.offerCreateAdvancedFriendLevelTitle())
                    .textStyle(.paragraph)

                Text(L.offerCreateAdvancedFriendDescription())
                    .textStyle(.micro)
            }
            .foregroundColor(Appearance.Colors.gray3)

            SingleOptionPickerView(selectedOption: $selectedOption,
                                   options: options,
                                   useBackground: false,
                                   content: { option in
                if let option = option {
                    VStack {
                        Group {
                            friendPicker(forLevel: option.imageName)
                                .frame(maxWidth: .infinity)
                                .frame(height: imageHeight)
                                .overlay(
                                    Image(systemName: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .offset(x: -10, y: -10)
                                        .opacity(selectedOption == option ? 1 : 0)
                                )
                                .padding(Appearance.GridGuide.padding)
                        }
                        .background(selectedOption == option ?
                                    Appearance.Colors.gray2 : Appearance.Colors.gray1)
                        .cornerRadius(Appearance.GridGuide.buttonCorner)
                        .readSize { size in
                            imageHeight = size.width
                        }

                        Text(option.offerLabel)
                            .textStyle(.paragraphSemibold)
                            .foregroundColor(selectedOption == option ?
                                             Appearance.Colors.whiteText : Appearance.Colors.gray3)
                    }
                }
            }, action: nil)
        }
    }

    private func friendPicker(forLevel level: String) -> some View {
        ZStack(alignment: .top) {
            Image(level)
                .padding(.top, Appearance.GridGuide.padding)

            Image(data: avatar, placeholder: R.image.marketplace.defaultAvatar.name)
                .resizable()
                .scaledToFill()
                .frame(size: Appearance.GridGuide.feedAvatarSize)
                .clipped()
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

#if DEBUG || DEVEL
// swiftlint:disable type_name
struct OfferAdvanceFilterFriendDegreeViewPreview: PreviewProvider {
    static var previews: some View {
        OfferAdvanceFilterFriendDegreeView(
            avatar: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 1),
            selectedOption: .constant(.firstDegree)
        )
        .background(Color.black)
        .previewDevice("iPhone 11")

        OfferAdvanceFilterFriendDegreeView(
            selectedOption: .constant(.firstDegree)
        )
            .background(Color.black)
        .previewDevice("iPhone SE")
    }
}
#endif
