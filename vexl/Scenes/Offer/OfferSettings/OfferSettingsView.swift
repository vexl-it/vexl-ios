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

    private var springAnimation: Animation {
        .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)
    }

    // swiftlint: disable closure_body_length
    var body: some View {
        VStack {
            HeaderTitleView(title: viewModel.headerTitle, showsSeparator: true) {
                viewModel.action.send(.dismissTap)
            }

            ScrollView(showsIndicators: false) {
                if viewModel.state != .initial {

                    if !viewModel.isOfferNew {
                        OfferStatusView(isActive: viewModel.offer.isActive,
                                        showDeleteButton: viewModel.showDeleteButton,
                                        pauseAction: {
                            viewModel.action.send(.activate)
                        },
                                        deleteAction: {
                            viewModel.action.send(.delete)
                        })
                    }

                    OfferDescriptionView(text: $viewModel.offer.description)
                        .padding(.bottom, Appearance.GridGuide.padding)

                    Group {
                        OfferCurrencyPickerView(selectedOption: $viewModel.offer.currency)
                            .padding(.bottom, Appearance.GridGuide.padding)

                        if let currency = viewModel.offer.currency {
                            OfferAmountRangeView(currency: currency,
                                                 currentValue: $viewModel.offer.currentAmountRange,
                                                 sliderBounds: viewModel.offer.amountRange,
                                                 minAmountTextFieldViewModel: viewModel.minAmountTextFieldViewModel,
                                                 maxAmountTextFieldViewModel: viewModel.maxAmountTextFieldViewModel)
                        }
                    }
                    .onChange(of: viewModel.offer.currency) { currency in
                        viewModel.offer.update(newCurrency: currency, resetAmount: true)
                    }

                    OfferFeePickerView(feeLabel: "\(Int(viewModel.offer.feeAmount))%",
                                       minValue: viewModel.minFee,
                                       maxValue: viewModel.maxFee,
                                       selectedOption: $viewModel.offer.selectedFeeOption,
                                       feeValue: $viewModel.offer.feeAmount)

                    OfferLocationPickerView(
                        items: $viewModel.locationViewModels,
                        addLocation: {
                            viewModel.action.send(.addLocation)
                        },
                        deleteLocation: { id in
                            viewModel.action.send(.deleteLocation(id: id))
                        }
                    )
                    .padding(.top, Appearance.GridGuide.largePadding1)

                    OfferTradeLocationPickerView(selectedOption: $viewModel.offer.selectedTradeStyleOption)

                    OfferPaymentMethodView(selectedOptions: $viewModel.offer.selectedPaymentMethodOptions)
                        .padding(.top, Appearance.GridGuide.largePadding1)

                    OfferTriggersView(currency: viewModel.triggerCurrency,
                                      showDeleteTrigger: viewModel.showDeleteTrigger,
                                      selectedActivateOption: $viewModel.offer.selectedPriceTrigger,
                                      selectedActivateAmount: $viewModel.offer.selectedPriceTriggerAmount,
                                      deleteTime: $viewModel.deleteTime,
                                      deleteTimeUnit: $viewModel.deleteTimeUnit)
                    .padding(.top, Appearance.GridGuide.mediumPadding2)

                    OfferAdvancedFilterView(
                        avatar: viewModel.userAvatar,
                        selectedTypeOptions: $viewModel.offer.selectedBTCOption,
                        selectedFriendDegreeOption: $viewModel.offer.selectedFriendDegreeOption,
                        groupRows: $viewModel.groupRows,
                        selectedGroup: $viewModel.offer.selectedGroup,
                        showContactsAndGroups: viewModel.isOfferNew
                    )
                    .padding(.top, Appearance.GridGuide.largePadding1)

                    LargeSolidButton(title: viewModel.actionTitle,
                                     font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                     style: .main,
                                     isFullWidth: true,
                                     isEnabled: .constant(viewModel.isButtonActive),
                                     action: { viewModel.action.send(.createOffer) })
                        .padding(.vertical, Appearance.GridGuide.largePadding1)
                }
            }
        }
        .padding(Appearance.GridGuide.padding)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .overlay(progressView)
    }

    private var progressView: some View {
        ZStack(alignment: .bottom) {
            if viewModel.showEncryptionLoader {
                Color.black
                    .opacity(Appearance.dimmingViewOpacity)
                    .transition(.opacity)
                    .zIndex(0)

                OfferSettingsProgressView(currentValue: viewModel.encryptionProgress,
                                          maxValue: viewModel.encryptionMaxProgress)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(springAnimation, value: viewModel.showEncryptionLoader)
    }
}

#if DEBUG || DEVEL
struct CreateOfferViewPreview: PreviewProvider {
    static var progressViewModel: OfferSettingsViewModel {
        let vm = OfferSettingsViewModel(offerType: .sell, offerKey: ECCKeys())
        vm.showEncryptionLoader = true
        return vm
    }

    static var previews: some View {
        OfferSettingsView(viewModel: progressViewModel)
            .previewDevice("iPhone 11")

        OfferSettingsView(viewModel: .init(offerType: .sell, offerKey: ECCKeys()))
            .previewDevice("iPhone 11")

        OfferSettingsView(viewModel: .init(offerType: .buy, offerKey: ECCKeys()))
            .previewDevice("iPhone 11")

        OfferSettingsView(viewModel: .init(offerType: .sell, offerKey: ECCKeys()))
            .previewDevice("iPod touch (7th generation)")

        OfferSettingsView(viewModel: .init(offerType: .buy, offerKey: ECCKeys()))
            .previewDevice("iPhone SE")
    }
}
#endif
