//
//  RegisterNameAvatarView+PhoneVerification.swift
//  vexl
//
//  Created by Diego Espinoza on 1/03/22.
//

import Foundation
import SwiftUI
import Cleevio

struct RegisterNameAvatarStartView: View {
    var body: some View {
        VStack {
            Image(R.image.onboarding.phoneVerified.name)

            Text(L.registerNameAvatarPhoneValidated())
                .textStyle(.paragraphBold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Appearance.GridGuide.padding)
                .padding(.top, Appearance.GridGuide.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RegisterNameAvatarStartViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarStartView()
            .background(Color.black)
    }
}
