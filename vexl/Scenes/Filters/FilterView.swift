//
//  FilterView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 23.05.2022.
//

import SwiftUI
import Cleevio

struct FilterView: View {
    enum UIProperties {
        static let mainButtonHeight: CGFloat = 40
    }

    @ObservedObject var viewModel: FilterViewModel

    private var scrollViewBottomPadding: CGFloat {
        UIProperties.mainButtonHeight + Appearance.GridGuide.padding * 2
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Appearance.GridGuide.padding) {
                    FilterHeaderView(
                        filterType: viewModel.filterType,
                        resetAction: { viewModel.send(action: .resetFilter) },
                        closeAction: { viewModel.send(action: .dismissTap) }
                    )

                    Group {
                        amount

                        OfferLocationPickerView(
                            items: viewModel.locations,
                            addLocation: { viewModel.send(action: .addLocation) },
                            deleteLocation: { id in
                                viewModel.send(action: .deleteLocation(id: id))
                            }
                        )

                        OfferPaymentMethodView(
                            selectedOptions: $viewModel.selectedPaymentMethodOptions
                        )

                        Divider()
                            .background(Appearance.Colors.gray4)
                            .padding(.top, Appearance.GridGuide.padding)

                        OfferAdvancedFilterView(
                            selectedTypeOptions: $viewModel.selectedBTCOptions,
                            selectedFriendSourceOptions: $viewModel.selectedFriendSources,
                            selectedFriendDegreeOption: $viewModel.selectedFriendDegreeOption
                        )
                    }
                    .padding(.horizontal, Appearance.GridGuide.padding)
                }
                .padding(.bottom, scrollViewBottomPadding)
            }

            SolidButton(Text("Apply filter"),
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.welcome,
                        dimensions: SolidButtonDimension.largeButton,
                        action: {
                viewModel.send(action: .applyFilter)
            })
            .padding(.horizontal, Appearance.GridGuide.padding)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var amount: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            OfferAmountRangeView(
                currencySymbol: "$",
                currentValue: $viewModel.currentAmountRange,
                sliderBounds: viewModel.amountRange
            )

            OfferFeePickerView(
                feeLabel: "10%",
                selectedOption: $viewModel.selectedFeeOption,
                feeValue: $viewModel.feeAmount
            )
        }
    }
}

#if DEBUG || DEVEL
struct FilterViewPreview: PreviewProvider {
    static var previews: some View {
        FilterView(viewModel: .init(offerFilter: .stub))
    }
}
#endif
