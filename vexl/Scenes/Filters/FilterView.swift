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
    @State private var imageHeight: CGFloat = .zero

    private var scrollViewBottomPadding: CGFloat {
        Appearance.GridGuide.baseHeight + Appearance.GridGuide.padding * 2
    }

    var body: some View {
        VStack(spacing: 0) {
            FilterHeaderView(
                filterType: viewModel.filterType,
                resetAction: { viewModel.send(action: .resetFilter) },
                closeAction: { viewModel.send(action: .dismissTap) }
            )

            scrollableContent
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var scrollableContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: Appearance.GridGuide.padding) {
                Group {
                    amount

                    OfferLocationPickerView(
                        items: $viewModel.locationViewModels,
                        addLocation: {
                            viewModel.action.send(.addLocation)
                        },
                        deleteLocation: { id in
                            viewModel.action.send(.deleteLocation(id: id))
                        }
                    )

                    OfferPaymentMethodView(
                        selectedOptions: $viewModel.selectedPaymentMethodOptions
                    )

                    Divider()
                        .background(Appearance.Colors.gray4)
                        .padding(.top, Appearance.GridGuide.padding)

                    advancedFilter

                    LargeSolidButton(title: L.filterApply(),
                                     font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                     style: .main,
                                     isFullWidth: true,
                                     isEnabled: .constant(true),
                                     action: {
                        viewModel.send(action: .applyFilter)
                    })
                    .padding(.vertical, Appearance.GridGuide.largePadding1)
                }
                .padding(.horizontal, Appearance.GridGuide.padding)
            }
            .padding(.top, Appearance.GridGuide.padding)
        }
    }

    private var amount: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            OfferCurrencyPickerView(selectedOption: $viewModel.currency)

            if let currency = viewModel.currency {
                OfferAmountRangeView(
                    currency: currency,
                    currentValue: $viewModel.currentAmountRange,
                    sliderBounds: viewModel.amountRange,
                    minAmountTextFieldViewModel: viewModel.minAmountTextFieldViewModel,
                    maxAmountTextFieldViewModel: viewModel.maxAmountTextFieldViewModel
                )

                feeOptions
            }
        }
    }

    @ViewBuilder
    private var feeOptions: some View {
        feePicker

        if viewModel.selectedFeeOptions.contains(.withFee) {
            feeAmountSlider
        }
    }

    @ViewBuilder
    private var feePicker: some View {
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

    @ViewBuilder
    private var feeAmountSlider: some View {
        VStack(alignment: .leading) {
            Text(viewModel.formatedFeeAmount)
                .textStyle(.paragraphMedium)
                .foregroundColor(Appearance.Colors.whiteText)
                .padding(Appearance.GridGuide.padding)

            SliderView(
                thumbColor: UIColor(Appearance.Colors.whiteText),
                minTrackColor: UIColor(Appearance.Colors.whiteText),
                maxTrackColor: UIColor(Appearance.Colors.gray2),
                minValue: viewModel.minFee,
                maxValue: viewModel.maxFee,
                value: $viewModel.feeAmount
            )
            .padding(.horizontal, Appearance.GridGuide.point)
            .padding(.bottom, Appearance.GridGuide.padding)
        }
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
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

            friendLevelPicker

            if !viewModel.groupRows.isEmpty {
                FilterGroupView(groupRows: $viewModel.groupRows, selectedGroups: $viewModel.selectedGroups)
            }
        }
    }

    private var friendLevelPicker: some View {
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
                        friendPicker(forLevel: option.imageName)
                            .frame(maxWidth: .infinity)
                            .frame(height: imageHeight)
                            .overlay(
                                Image(systemName: "checkmark.circle.fill")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .offset(x: -10, y: -10)
                                    .opacity(viewModel.isFriendDegreeSelected(for: option) ? 1 : 0)
                            )
                            .readSize { size in
                                imageHeight = size.width
                            }
                    }
                },
                action: nil
            )
        }
    }

    private func friendPicker(forLevel level: String) -> some View {
        ZStack(alignment: .top) {
            Image(level)
                .padding(.top, Appearance.GridGuide.padding)

            Image(data: viewModel.userAvatar, placeholder: R.image.marketplace.defaultAvatar.name)
                .resizable()
                .scaledToFill()
                .frame(size: Appearance.GridGuide.feedAvatarSize)
                .clipped()
                .cornerRadius(Appearance.GridGuide.buttonCorner)
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
