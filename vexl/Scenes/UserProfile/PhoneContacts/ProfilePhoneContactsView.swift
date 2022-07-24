//
//  ImportContactsProfileView.swift
//  vexl
//
//  Created by Diego Espinoza on 18/07/22.
//

import SwiftUI

struct ProfilePhoneContactsView: View {

    @ObservedObject var viewModel: ImportContactsProfileViewModel

    var body: some View {
        VStack {
            ImportContactsView(viewModel: viewModel.importContactViewModel)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL

struct ImportContactsProfileViewPreview: PreviewProvider {
    static var previews: some View {
        ProfilePhoneContactsView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
