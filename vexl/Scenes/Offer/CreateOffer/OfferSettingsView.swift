//
//  CreateOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI
import Cleevio

struct OfferSettingsView: View {

    @ObservedObject var viewModel: OfferSettingsViewModel

    var body: some View {
        VStack {
            HeaderTitleView(title: viewModel.headerTitle, showsSeparator: true) {
                viewModel.action.send(.dismissTap)
            }

            ScrollView(showsIndicators: false) {
                if viewModel.state != .initial {

                    OfferStatusView(isActive: viewModel.isActive,
                                    showDeleteButton: viewModel.showDeleteButton,
                                    pauseAction: {
                        viewModel.action.send(.activate)
                    },
                                    deleteAction: {
                        viewModel.action.send(.delete)
                    })

                    OfferDescriptionView(text: $viewModel.description)
                        .padding(.bottom, Appearance.GridGuide.padding)

                    OfferAmountRangeView(currencySymbol: viewModel.currency.sign,
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

                    OfferTriggersView(showDeleteTrigger: viewModel.showDeleteTrigger,
                                      selectedActivateOption: $viewModel.selectedPriceTrigger,
                                      selectedActivateAmount: $viewModel.selectedPriceTriggerAmount,
                                      deleteTime: $viewModel.deleteTime,
                                      deleteTimeUnit: $viewModel.deleteTimeUnit)
                    .padding(.top, Appearance.GridGuide.mediumPadding2)

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
        OfferSettingsView(viewModel: .init(offerType: .sell, offerKey: ECCKeys()))
            .previewDevice("iPhone 11")

        OfferSettingsView(viewModel: .init(offerType: .buy, offerKey: ECCKeys()))
            .previewDevice("iPhone 11")
    }
}
#endif
