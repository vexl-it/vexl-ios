//
//  OfferLocationPickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI
import AVFoundation

typealias OfferLocationItemData = OfferLocationPickerView.LocationViewData

struct OfferLocationPickerView: View {

    let items: [OfferLocationItemData]
    let addLocation: () -> Void
    let deleteLocation: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {
            HStack {
                Image(R.image.offer.location.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)

                Text(L.offerCreateLocationTitle())
                    .textStyle(.h2)
            }
            .padding(.vertical, Appearance.GridGuide.point)
            .foregroundColor(Appearance.Colors.whiteText)

            ForEach(items, id: \.self) { item in
                LocationView(name: item.name,
                             distance: item.distance,
                             deleteAction: {
                    deleteLocation(item.id)
                })
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
                .textStyle(.descriptionSemibold)
        }
        .foregroundColor(Appearance.Colors.gray3)
        .padding(Appearance.GridGuide.padding)
        .frame(maxWidth: .infinity)
    }
}

extension OfferLocationPickerView {

    struct LocationViewData: Identifiable, Hashable {
        var id: Int
        let name: String
        let distance: String

        static func stub() -> [LocationViewData] {
            [
                .init(id: 1, name: "Prague", distance: "1km"),
                .init(id: 2, name: "Brno", distance: "2km")
            ]
        }
    }

    struct LocationView: View {

        let name: String
        let distance: String
        let deleteAction: () -> Void

        var body: some View {
            HStack {
                HStack {
                    Text(name)
                        .foregroundColor(Appearance.Colors.green5)

                    Spacer()

                    Rectangle()
                        .frame(width: 2)
                        .foregroundColor(Appearance.Colors.gray2)
                        .padding(.trailing, Appearance.GridGuide.smallPadding)

                    Text(distance)
                        .foregroundColor(Appearance.Colors.green5)
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
struct OfferLocationPickerViewPreview: PreviewProvider {
    static var previews: some View {
        OfferLocationPickerView(items: OfferLocationItemData.stub(),
                                addLocation: { },
                                deleteLocation: { _ in })
            .previewDevice("iPhone 11")
            .background(Color.black)
            .frame(height: 150)
    }
}
#endif
