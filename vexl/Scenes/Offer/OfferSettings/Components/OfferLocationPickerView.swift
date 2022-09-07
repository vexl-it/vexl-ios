//
//  OfferLocationPickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI
import AVFoundation

struct OfferLocationPickerView: View {
    @Binding var items: [OfferLocationViewModel]
    let addLocation: () -> Void
    let deleteLocation: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {
            HStack {
                Image(R.image.offer.location.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)

                Text(L.offerCreateLocationTitle())
                    .textStyle(.titleSemiBold)
            }
            .padding(.vertical, Appearance.GridGuide.point)
            .foregroundColor(Appearance.Colors.whiteText)

            ForEach(items) { item in
                LocationView(viewModel: item) {
                    deleteLocation(item.id)
                }
            }

            if items.count < Constants.maxNumberOfLocations {
                DottedButton(color: Appearance.Colors.gray3,
                             content: {
                    addLocationLabel
                },
                             action: {
                    addLocation()
                })
            }
        }
    }

    private var addLocationLabel: some View {
        HStack {
            Image(systemName: "plus")

            Text(L.offerCreateLocationAdd())
                .textStyle(.descriptionBold)
        }
        .foregroundColor(Appearance.Colors.gray3)
        .padding(Appearance.GridGuide.padding)
        .frame(maxWidth: .infinity)
    }
}

extension OfferLocationPickerView {
    struct LocationView: View {
        @ObservedObject var viewModel: OfferLocationViewModel
        let deleteAction: () -> Void
        @State private var suggestionSize: CGSize = .zero

        var body: some View {
            VStack {
                locationInput

                switch viewModel.state {
                case .results(let suggestions):
                    suggestionsView(suggestions: suggestions)
                case .empty:
                    Text(L.offerLocationSuggestionsEmpty())
                        .textStyle(.paragraphMedium)
                        .foregroundColor(.white)
                        .padding()
                case .error:
                    Text(L.generalInternalServerError())
                        .textStyle(.paragraphMedium)
                        .foregroundColor(.white)
                        .padding()
                case .noUserInteraction:
                    EmptyView()
                }
            }
        }

        private var locationInput: some View {
            HStack {
                IsFocusTextField(
                    placeholder: L.offerLocationPlaceholder(),
                    textColor: R.color.yellow100(),
                    text: $viewModel.name,
                    isEnabled: viewModel.canBeModified,
                    isFocused: $viewModel.isTextFieldFocused
                )
                .padding(Appearance.GridGuide.mediumPadding1)
                .background(Appearance.Colors.gray1)
                .cornerRadius(Appearance.GridGuide.buttonCorner)

                Button {
                    deleteAction()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Appearance.Colors.gray2)
                }
                .padding(.leading, Appearance.GridGuide.padding)
            }
        }

        private func suggestionsView(suggestions: [LocationSuggestion]) -> some View {
            ScrollView {
                VStack {
                    ForEach(suggestions, id: \.self) { suggestionInfo in
                        VStack {
                            Group {
                                Text(suggestionInfo.city)
                                    .textStyle(.paragraphMedium)

                                Text(suggestionInfo.suggestSecondRow ?? "")
                                    .textStyle(.paragraphSmall)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                        }
                        .padding()
                        .readSize(onChange: {
                            if suggestionSize.height.isZero {
                                suggestionSize = $0
                            }
                        })
                        .background(Color.black)
                        .onTapGesture {
                            viewModel.send(action: .suggestionTap(suggestionInfo))
                        }

                        HLine(color: Appearance.Colors.whiteOpaque,
                              height: 1)
                    }
                }
            }
            .frame(height: min(200, CGFloat(suggestions.count + 1) * suggestionSize.height))
        }
    }
}

#if DEBUG || DEVEL
struct OfferLocationPickerViewPreview: PreviewProvider {
    static var previews: some View {
        OfferLocationPickerView(
            items: .constant([OfferLocationViewModel(location: nil, currentLocations: [])]),
            addLocation: { },
            deleteLocation: { _ in }
        )
        .previewDevice("iPhone 11")
        .background(Color.black)
        .frame(height: 150)
    }
}
#endif
