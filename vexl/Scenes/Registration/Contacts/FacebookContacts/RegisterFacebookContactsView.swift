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
    private let transition = AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .scale).combined(with: .opacity)

    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .requestAccess:
                RequestAccessContactsView(viewModel: viewModel.facebookViewModel)
                    .transition(transition)
            case .importFacebookContacts:
                ImportContactsView(viewModel: viewModel.importFacebookContactsViewModel)
                    .transition(transition)
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
