//
//  RegisterPhoneContactsView.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import SwiftUI
import Cleevio

struct RegisterContactsView: View {

    @ObservedObject var viewModel: RegisterContactsViewModel

    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .phone:
                PhoneContactsView(viewModel: viewModel.phoneViewModel)
            case .importPhoneContacts:
                ImportContactsView(viewModel: viewModel.importPhoneContactsViewModel)
            case .facebook, .importFacebookContacts:
                Text("contacts").foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct RegisterContactsViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterContactsView(viewModel: .init())
    }
}
