//
//  ChatIdentityRequestView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatIdentityRequestView: View {

    var body: some View {
        VStack {
            Text("Identity reveal request")
                .foregroundColor(Appearance.Colors.gray3)
                .textStyle(.description)
        }
    }
}

#if DEBUG || DEVEL

struct ChatIdentityRequestViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatIdentityRequestView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
