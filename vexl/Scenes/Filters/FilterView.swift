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

            LargeSolidButton(title: L.filterApply(),
                             font: Appearance.TextStyle.titleSmallBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
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

                    advancedFilter
                }
                .padding(.horizontal, Appearance.GridGuide.padding)
            }
            .padding(.top, Appearance.GridGuide.padding)
            .padding(.bottom, scrollViewBottomPadding)
        }
    }

    private var amount: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            OfferCurrencyPickerView(selectedOption: $viewModel.currency)

            OfferAmountRangeView(
                currency: viewModel.currency,
                currentValue: $viewModel.currentAmountRange,
                sliderBounds: viewModel.amountRange
            )

            MultipleOptionPickerView(
                selectedOptions: $viewModel.selectedFeeOptions,
                options: OfferFeeOption.allCases,
                content: { option in
                    Text(option.title)
                        .frame(maxWidth: .infinity)
                },
                action: nil
            )
        }
    }

    @ViewBuilder
    private var advancedFilter: some View {
        VStack {
            HStack {
                Image(R.image.offer.mathAdvanced.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)

                Text(L.offerCreateAdvancedTitle())
                    .textStyle(.titleSemiBold)
                    .foregroundColor(Appearance.Colors.whiteText)

                Spacer()

                Image(systemName: "chevron.up")
                    .foregroundColor(Appearance.Colors.gray3)
            }
            OfferAdvancedFilterBTCNetworkView(selectedOptions: $viewModel.selectedBTCOptions)
                .padding(.top, Appearance.GridGuide.padding)

            VStack(alignment: .leading) {
                Group {
                    Text(L.offerCreateAdvancedFriendLevelTitle())
                        .textStyle(.paragraph)

                    Text(L.offerCreateAdvancedFriendDescription())
                        .textStyle(.micro)
                }
                .foregroundColor(Appearance.Colors.gray3)

                MultipleOptionPickerView(
                    selectedOptions: $viewModel.selectedFriendDegreeOptions,
                    options: OfferFriendDegree.allCases,
                    content: { option in
                        if let option = option {
                            Image(option.imageName)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    Image(systemName: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .offset(x: -10, y: -10)
                                )
                        }
                    },
                    action: nil
                )
            }
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
