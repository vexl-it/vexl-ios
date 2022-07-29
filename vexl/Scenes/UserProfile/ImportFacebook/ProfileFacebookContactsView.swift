//
//  ImportFacebookProfileView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/07/22.
//

import SwiftUI

struct ProfileFacebookContactsView: View {

    @ObservedObject var viewModel: ProfileFacebookContactsViewModel

    var body: some View {
        ImportContactsView(viewModel: viewModel.importContactViewModel)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
