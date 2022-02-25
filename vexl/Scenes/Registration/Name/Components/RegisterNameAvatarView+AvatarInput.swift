//
//  RegisterNameAvatarView+AvatarInput.swift
//  vexl
//
//  Created by Diego Espinoza on 25/02/22.
//

import SwiftUI

extension RegisterNameAvatarView {

    struct AvatarInputView: View {

        let name: String

        var body: some View {
            RegistrationHeaderCardView(title: "title",
                                       subtitle: "bsubtitle",
                                       header: greetingView,
                                       content: Text("bottom").foregroundColor(.black))
                .padding(.all, Appearance.GridGuide.point)
        }

        var greetingView: some View {
            Text("Hey \(name)")
                .foregroundColor(Appearance.Colors.purple4)
                .textStyle(.h2)
        }
    }
}

struct RegisterNameAvatarInputViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarView.AvatarInputView(name: "Name")
    }
}
