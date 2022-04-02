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
        AlertContainerView(error: $viewModel.error) {
            LoadingContainerView(loading: viewModel.loading) {
                ContentView(viewModel: viewModel)
            }
        }
    }
}

extension RegisterContactsView {

    struct ContentView: View {
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
        }
    }
}

struct RegisterContactsViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterContactsView(viewModel: .init(username: "Diego"))
    }
}
