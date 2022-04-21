//
//  OfferLocationPickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI
import AVFoundation

struct OfferLocationPickerView: View {

    let addLocation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {
            HStack {
                Image(R.image.offer.location.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)

                Text("Location")
                    .textStyle(.h3)
            }
            .padding(.vertical, Appearance.GridGuide.point)
            .foregroundColor(Appearance.Colors.whiteText)

            LocationItem(name: "Prague", distance: "1km") {
                
            }

            LocationItem(name: "Prague", distance: "1km") {
                
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

            Text("Another Location")
                .textStyle(.descriptionSemibold)
        }
        .foregroundColor(Appearance.Colors.gray3)
        .padding(Appearance.GridGuide.padding)
        .frame(maxWidth: .infinity)
    }
}

extension OfferLocationPickerView {

    struct LocationItem: View {

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
        OfferLocationPickerView(addLocation: {
            
        })
            .previewDevice("iPhone 11")
            .background(Color.black)
            .frame(height: 150)
    }
}
#endif
