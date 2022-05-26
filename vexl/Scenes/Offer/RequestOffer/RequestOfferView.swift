//
//  RequestOfferView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import SwiftUI

struct RequestOfferView: View {
    @ObservedObject var viewModel: RequestOfferViewModel

    var body: some View {
        Text("Hello World")
    }
}

#if DEBUG || DEVEL
struct RequestOfferViewPreview: PreviewProvider {
    static var previews: some View {
        RequestOfferView(viewModel: .init())
    }
}
#endif
