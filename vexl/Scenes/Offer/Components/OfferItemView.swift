//
//  UserOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/05/22.
//

import SwiftUI

struct OfferItemView: View {

    enum UIProperties {
        static let editOfferButtonHeight: CGFloat = 48
    }

    let data: OfferDetailViewData
    let editOfferAction: () -> Void

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            bubble

            footer
        }
    }

    private var bubble: some View {
        OfferInformationDetailView(
            data: data,
            useInnerPadding: true,
            showBackground: true
        )
    }

    private var footer: some View {
        HStack {
            ContactAvatarInfo(
                isAvatarWithOpacity: false,
                title: L.offerMine(),
                subtitle: L.offerAdded(Formatters.userOfferDateFormatter.string(from: data.createdDate))
            )

            Button(action: editOfferAction, label: {
                Text(L.offerEdit())
                    .foregroundColor(Appearance.Colors.yellow100)
            })
            .padding()
            .frame(height: UIProperties.editOfferButtonHeight)
            .background(Appearance.Colors.yellow20)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

// TODO: [offer refactor] scene preview
//#if DEBUG || DEVEL
//struct OfferItemViewPreview: PreviewProvider {
//    static var previews: some View {
//        let data = OfferDetailViewData(offer: .stub, isRequested: true)
//        ZStack {
//            Color.black
//                .edgesIgnoringSafeArea(.all)
//
//            OfferItemView(data: data, editOfferAction: {})
//                .frame(height: 250)
//        }
//    }
//}
//#endif
