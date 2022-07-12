//
//  ChatImagePreviewView.swift
//  vexl
//
//  Created by Diego Espinoza on 16/06/22.
//

import SwiftUI

struct ChatExpandedImageView: View {

    @ObservedObject var viewModel: ChatExpandedImageViewModel

    var body: some View {
        VStack(alignment: .trailing) {
            Button {
                viewModel.action.send(.dismissTap)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Appearance.Colors.gray3)
            }

            Image(data: viewModel.image, placeholder: "")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL

struct ChatExpandedImageViewPreview: PreviewProvider {
    static var previews: some View {
        ChatExpandedImageView(viewModel: .init(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.5)!))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
