//
//  ImportContactsProfileView.swift
//  vexl
//
//  Created by Diego Espinoza on 18/07/22.
//

import SwiftUI

struct ImportContactsProfileView: View {

    @ObservedObject var viewModel: ImportContactsProfileViewModel

    var body: some View {
        Text("1234")
    }
}

#if DEBUG || DEVEL

struct ImportContactsProfileViewPreview: PreviewProvider {
    static var previews: some View {
        ImportContactsProfileView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
