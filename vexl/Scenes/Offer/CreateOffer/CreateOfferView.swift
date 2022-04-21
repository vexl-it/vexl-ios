//
//  CreateOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct CreateOfferView: View {

    @ObservedObject var viewModel: CreateOfferViewModel

    var body: some View {
        VStack {
            OfferHeaderView {
                viewModel.action.send(.dismissTap)
            }

            ScrollView {
                OfferStatusView(pauseAction: {
                    viewModel.action.send(.pause)
                },
                                deleteAction: {
                    viewModel.action.send(.delete)
                })
                .padding(Appearance.GridGuide.padding)
                
                
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL
struct CreateOfferViewPreview: PreviewProvider {
    static var previews: some View {
        CreateOfferView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
#endif
