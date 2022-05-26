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
            HeaderTitleView(title: viewModel.headerTitle, showSeparator: true) {
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
                    .padding(Appearance.GridGuide.padding)

                    OfferDescriptionView(text: $viewModel.description)
                        .padding(.horizontal, Appearance.GridGuide.point)
                        .padding(.bottom, Appearance.GridGuide.largePadding1)

                    OfferAmountRangeView(currencySymbol: viewModel.currencySymbol,
                                         currentValue: $viewModel.currentAmountRange,
                                         sliderBounds: viewModel.amountRange)
                        .padding(.horizontal, Appearance.GridGuide.point)

                    OfferFeePickerView(feeLabel: "\(viewModel.feeValue)%",
                                       selectedOption: $viewModel.selectedFeeOption,
                                       feeValue: $viewModel.feeAmount)
                        .padding(.horizontal, Appearance.GridGuide.point)

                    OfferLocationPickerView(items: viewModel.locations,
                                            addLocation: {
                        viewModel.action.send(.addLocation)
                    },
                                            deleteLocation: { id in
                        viewModel.action.send(.deleteLocation(id: id))
                    })
                        .padding(.top, Appearance.GridGuide.largePadding1)
                        .padding(.horizontal, Appearance.GridGuide.point)

                    OfferTradeLocationPickerView(selectedOption: $viewModel.selectedTradeStyleOption)
                        .padding(.horizontal, Appearance.GridGuide.point)

                    OfferPaymentMethodView(selectedOptions: $viewModel.selectedPaymentMethodOptions)
                        .padding(.top, Appearance.GridGuide.largePadding1)
                        .padding(.horizontal, Appearance.GridGuide.point)

                    OfferAdvancedFilterView(
                        selectedTypeOptions: $viewModel.selectedBTCOption,
                        selectedFriendDegreeOption: $viewModel.selectedFriendDegreeOption
                    )
                    .padding(.top, Appearance.GridGuide.largePadding1)
                    .padding(.horizontal, Appearance.GridGuide.point)

                    SolidButton(Text(viewModel.actionTitle)
                                    .padding(.horizontal,
                                             Appearance.GridGuide.mediumPadding1),
                                isEnabled: .constant(viewModel.isCreateEnabled),
                                fullWidth: true,
                                font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                colors: SolidButtonColor.welcome,
                                dimensions: SolidButtonDimension.largeButton,
                                action: {
                        viewModel.action.send(.createOffer)
                    })
                        .padding(.horizontal, Appearance.GridGuide.point)
                        .padding(.vertical, Appearance.GridGuide.largePadding1)
                }
            }
        }
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
