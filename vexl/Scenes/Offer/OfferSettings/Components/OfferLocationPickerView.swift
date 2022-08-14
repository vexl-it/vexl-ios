//
//  OfferLocationPickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI
import AVFoundation

//typealias OfferLocationItemData = OfferLocationPickerView.LocationViewData

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

            DottedButton(color: Appearance.Colors.gray3,
                         content: {
                addLocationLabel
            },
                         action: {
                addLocation()
            })
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

//    struct LocationViewData: Identifiable, Hashable {
//        var id: Int
//        let name: String
//        let distance: String
//
//        static func stub() -> [LocationViewData] {
//            [
//                .init(id: 1, name: "Prague", distance: "1km"),
//                .init(id: 2, name: "Brno", distance: "2km")
//            ]
//        }
//    }

    struct LocationView: View {
        @ObservedObject var viewModel: OfferLocationViewModel
        let deleteAction: () -> Void

        var body: some View {
            VStack {
                locationInput

                switch viewModel.state {
                case .results(let suggestions):
                    suggestionsView(suggestions: suggestions)
                case .empty:
                    Text("No suggestions")
                        .textStyle(.paragraphMedium)
                        .foregroundColor(.white)
                        .padding()
                case .error:
                    Text("There was some error")
                        .textStyle(.paragraphMedium)
                        .foregroundColor(.white)
                        .padding()
                case .noUserInteraction:
                    EmptyView()
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Appearance.Colors.whiteText))
                        .padding()
                }
            }
        }

        private func suggestionsView(suggestions: [LocationSuggestion]) -> some View {
            ScrollView {
                VStack {
                    ForEach(suggestions, id: \.self) { suggestionInfo in
                        Text(suggestionInfo.suggestion)
                            .textStyle(.paragraphMedium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .onTapGesture {
                                viewModel.send(action: .suggestionTap(suggestionInfo))
                            }
                    }
                }
            }
            .frame(height: 200)
        }

        private var locationInput: some View {
            HStack {
                HStack {
                    IsFocusTextField(
                        placeholder: "City",
                        text: $viewModel.name,
                        isFocused: $viewModel.isTextFieldFocused
                    )
//                    PlaceholderTextField(
//                        placeholder: "City",
//                        textColor: Appearance.Colors.yellow100,
//                        text: $viewModel.name
//                    )

                    Spacer()

                    VLine(color: Appearance.Colors.gray2,
                          width: 2)
                        .padding(.trailing, Appearance.GridGuide.smallPadding)

                    Text("1km")
                        .foregroundColor(Appearance.Colors.whiteText)
                }
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
    }
}

#if DEBUG || DEVEL
//struct OfferLocationPickerViewPreview: PreviewProvider {
//    static var previews: some View {
//        OfferLocationPickerView(items: OfferLocationItemData.stub(),
//                                addLocation: { },
//                                deleteLocation: { _ in })
//            .previewDevice("iPhone 11")
//            .background(Color.black)
//            .frame(height: 150)
//    }
//}
#endif
