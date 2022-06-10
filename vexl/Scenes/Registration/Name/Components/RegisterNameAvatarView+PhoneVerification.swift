//
//  RegisterNameAvatarView+PhoneVerification.swift
//  vexl
//
//  Created by Diego Espinoza on 1/03/22.
//

import Foundation
import SwiftUI
import Cleevio

extension RegisterNameAvatarView {

    struct PhoneVerified: View {
        var body: some View {
            VStack {
                Image(R.image.onboarding.phoneVerified.name)

                Text(L.registerNameAvatarPhoneValidated())
                    .textStyle(.h3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Appearance.GridGuide.padding)
                    .padding(.top, Appearance.GridGuide.largePadding1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// swiftlint:disable type_name
struct RegisterNameAvatarPhoneVerifiedViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarView.PhoneVerified()
            .background(Color.black)
    }
}
