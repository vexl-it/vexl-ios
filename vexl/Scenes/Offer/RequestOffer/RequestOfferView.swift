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
        VStack {
            header
        }
    }

    private var header: some View {
        HStack {
            Text("Offer")
                .frame(maxWidth: .infinity)
            
            closeButton
        }
    }

    private var closeButton: some View {
        Button(action: { viewModel.send(action: .dismissTap) }, label: {
            Image(systemName: "xmark")
                .foregroundColor(Appearance.Colors.whiteText)
                .frame(size: Appearance.GridGuide.baseButtonSize)
        })
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Appearance.Colors.gray1)
        )
    }
}

#if DEBUG || DEVEL
struct RequestOfferViewPreview: PreviewProvider {
    static var previews: some View {
        RequestOfferView(viewModel: .init())
    }
}
#endif
