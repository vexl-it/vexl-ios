//
//  FilterView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 23.05.2022.
//

import SwiftUI
import Cleevio

struct FilterView: View {
    @ObservedObject var viewModel: FilterViewModel

    private var scrollViewBottomPadding: CGFloat {
        Appearance.GridGuide.baseHeight + Appearance.GridGuide.padding * 2
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                FilterHeaderView(
                    filterType: viewModel.filterType,
                    resetAction: { viewModel.send(action: .resetFilter) },
                    closeAction: { viewModel.send(action: .dismissTap) }
                )

                scrollableContent
            }

            SolidButton(Text(L.filterApply()),
                        font: Appearance.TextStyle.titleSmallBold.font.asFont,
                        colors: SolidButtonColor.main,
                        dimensions: SolidButtonDimension.largeButton,
                        action: {
                viewModel.send(action: .applyFilter)
            })
            .padding(.horizontal, Appearance.GridGuide.padding)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var scrollableContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Appearance.GridGuide.padding) {
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
                        selectedFriendDegreeOption: $viewModel.selectedFriendDegreeOption
                    )
                }
                .padding(.horizontal, Appearance.GridGuide.padding)
            }
            .padding(.top, Appearance.GridGuide.padding)
            .padding(.bottom, scrollViewBottomPadding)
        }
    }

    private var amount: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            OfferAmountRangeView(
                currencySymbol: viewModel.currencySymbol,
                currentValue: $viewModel.currentAmountRange,
                sliderBounds: viewModel.amountRange
            )

            OfferFeePickerView(
                feeLabel: "\(viewModel.feeValue)%",
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
