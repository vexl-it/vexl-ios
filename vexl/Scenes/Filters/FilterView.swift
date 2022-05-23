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

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Appearance.GridGuide.padding) {
                    header

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
                    }
                    .padding(.horizontal, Appearance.GridGuide.padding)
                }
            }
            .padding(.bottom, 40 + 32)

            SolidButton(Text("Apply filter"),
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.welcome,
                        dimensions: SolidButtonDimension.largeButton,
                        action: {
                print("hey")
            })
            .padding(.horizontal, Appearance.GridGuide.padding)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var header: some View {
        VStack {
            HStack {
                VStack {
                    Group {
                        Text("Buy")
                            .textStyle(.h3)
                            .foregroundColor(Appearance.Colors.green1)
                        Text("Filter")
                            .textStyle(.h2)
                            .foregroundColor(Appearance.Colors.whiteText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: { viewModel.send(action: .dismissTap) }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Appearance.Colors.whiteText)
                        .frame(size: .init(width: 40, height: 40))
                })
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Appearance.Colors.gray1)
                )
            }
            .padding(.horizontal, Appearance.GridGuide.padding)

            Divider()
                .background(Appearance.Colors.gray4)
                .padding(.horizontal, -Appearance.GridGuide.padding)
        }
    }

    private var amount: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            RangePickerView(
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
        FilterView(viewModel: .init())
    }
}
#endif
