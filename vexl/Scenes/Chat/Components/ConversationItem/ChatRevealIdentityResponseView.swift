//
//  ChatRevealIdentityResponseView.swift
//  vexl
//
//  Created by Diego Espinoza on 7/07/22.
//

import SwiftUI

struct ChatRevealIdentityResponseView: View {

    let image: Data?
    let isAccepted: Bool

    var body: some View {
        VStack {
            if isAccepted {
                Text("Accepted")
                    .foregroundColor(.white)
            } else {
                Text("Rejected")
                    .foregroundColor(.white)
            }
        }
    }
}

#if DEBUG || DEVEL

struct ChatRevealIdentityResponseViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatRevealIdentityResponseView(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 1),
                                           isAccepted: true)

            ChatRevealIdentityResponseView(image: nil,
                                           isAccepted: false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
