//
//  CreateOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI
import Cleevio

struct CreateOfferView: View {

    @ObservedObject var viewModel: CreateOfferViewModel

    var body: some View {
        VStack {
            HeaderTitleView(title: viewModel.headerTitle, showsSeparator: true) {
                viewModel.action.send(.dismissTap)
            }

            ScrollView(showsIndicators: false) {
                if viewModel.state != .initial {

                    OfferStatusView(pauseAction: {
                        viewModel.action.send(.pause)
                    },
                                    deleteAction: {
                        viewModel.action.send(.delete)
                    })

                    OfferDescriptionView(text: $viewModel.description)
                        .padding(.bottom, Appearance.GridGuide.padding)

                    OfferAmountRangeView(currencySymbol: viewModel.currencySymbol,
                                         currentValue: $viewModel.currentAmountRange,
                                         sliderBounds: viewModel.amountRange)

                    OfferFeePickerView(feeLabel: "\(viewModel.feeValue)%",
                                       selectedOption: $viewModel.selectedFeeOption,
                                       feeValue: $viewModel.feeAmount)

                    OfferLocationPickerView(items: viewModel.locations,
                                            addLocation: {
                        viewModel.action.send(.addLocation)
                    },
                                            deleteLocation: { id in
                        viewModel.action.send(.deleteLocation(id: id))
                    })
                        .padding(.top, Appearance.GridGuide.largePadding1)

                    OfferTradeLocationPickerView(selectedOption: $viewModel.selectedTradeStyleOption)

                    OfferPaymentMethodView(selectedOptions: $viewModel.selectedPaymentMethodOptions)
                        .padding(.top, Appearance.GridGuide.largePadding1)

                    OfferAdvancedFilterView(
                        selectedTypeOptions: $viewModel.selectedBTCOption,
                        selectedFriendDegreeOption: $viewModel.selectedFriendDegreeOption
                    )
                    .padding(.top, Appearance.GridGuide.largePadding1)

                    LargeSolidButton(title: viewModel.actionTitle,
                                     font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                     style: .main,
                                     isFullWidth: true,
                                     isEnabled: .constant(viewModel.isCreateEnabled),
                                     action: {
                        viewModel.action.send(.createOffer)
                    })
                        .padding(.vertical, Appearance.GridGuide.largePadding1)
                }
            }
        }
        .padding(Appearance.GridGuide.padding)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL
struct CreateOfferViewPreview: PreviewProvider {
    static var previews: some View {
        CreateOfferView(viewModel: .init(offerType: .sell))
            .previewDevice("iPhone 11")

        CreateOfferView(viewModel: .init(offerType: .buy))
            .previewDevice("iPhone 11")
    }
}
#endif
