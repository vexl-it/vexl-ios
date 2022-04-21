//
//  CreateOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct CreateOfferView: View {

    @ObservedObject var viewModel: CreateOfferViewModel

    @State var sliderPosition: ClosedRange<Int> = 600...15_000

    var body: some View {
        VStack {
            OfferHeaderView {
                viewModel.action.send(.dismissTap)
            }

            ScrollView(showsIndicators: false) {
                OfferStatusView(pauseAction: {
                    viewModel.action.send(.pause)
                },
                                deleteAction: {
                    viewModel.action.send(.delete)
                })
                .padding(Appearance.GridGuide.padding)

                OfferRangePickerView(currencySymbol: viewModel.currencySymbol,
                                     currentValue: $sliderPosition,
                                     sliderBounds: 0...30_000)
                    .padding(.horizontal, Appearance.GridGuide.point)

                OfferFeePickerView()
                    .padding(.horizontal, Appearance.GridGuide.point)

                OfferLocationPickerView(items: viewModel.locations,
                                        addLocation: {
                    
                },
                                        deleteLocation: { _ in
                    
                })
                    .padding(.horizontal, Appearance.GridGuide.point)
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
