//
//  ImportFacebookProfileView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/07/22.
//

import SwiftUI

struct ImportFacebookProfileView: View {

    @ObservedObject var viewModel: ImportFacebookProfileViewModel

    var body: some View {
        ImportContactsView(viewModel: viewModel.importContactViewModel)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
}
