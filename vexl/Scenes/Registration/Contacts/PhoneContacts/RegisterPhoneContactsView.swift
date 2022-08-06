//
//  RegisterPhoneContactsView.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import SwiftUI
import Cleevio

struct RegisterPhoneContactsView: View {

    @ObservedObject var viewModel: RegisterContactsViewModel

    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .phone:
                RequestAccessContactsView(viewModel: viewModel.phoneViewModel)
            case .importPhoneContacts:
                ImportContactsView(viewModel: viewModel.importPhoneContactsViewModel)
            case .facebook:
                RequestAccessContactsView(viewModel: viewModel.facebookViewModel)
            case .importFacebookContacts:
                ImportContactsView(viewModel: viewModel.importFacebookContactsViewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .animation(.easeInOut(duration: 0.5), value: viewModel.currentState)
    }
}

struct RegisterPhoneContactsViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneContactsView(viewModel: .init(username: "Diego", avatar: nil))
    }
}

