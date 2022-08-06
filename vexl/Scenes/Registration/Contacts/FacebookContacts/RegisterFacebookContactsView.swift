//
//  RegisterPhoneContactsView.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import Foundation
import SwiftUI

struct RegisterFacebookContactsView: View {

    @ObservedObject var viewModel: RegisterFacebookContactsViewModel

    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .requestAccess:
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

struct RegisterFacebookContactsViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterFacebookContactsView(viewModel: .init())
    }
}
