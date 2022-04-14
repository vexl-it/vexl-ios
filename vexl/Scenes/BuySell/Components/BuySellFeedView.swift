//
//  BuySellInformationView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import SwiftUI

struct BuySellFeedView: View {

    let title: String
    let isRequested: Bool
    let location: String

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            Text(title)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding([.horizontal, .top], Appearance.GridGuide.mediumPadding1)

            BuySellFeedDetailView()
                .padding(.horizontal, Appearance.GridGuide.padding)

            // TODO: - set contact type from viewmodel + real action
            BuySellFeedFooterView(contactType: .facebook,
                                  isRequested: isRequested,
                                  location: location) {
                print("facebook")
            }
                .padding(.horizontal, Appearance.GridGuide.padding)
                .padding(.bottom, Appearance.GridGuide.padding)
        }
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

#if DEBUG || DEVEL
struct BuySellFeedViewViewPreview: PreviewProvider {
    static var previews: some View {
        BuySellFeedView(title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                        isRequested: true,
                        location: "Prague")
            .previewDevice("iPhone 11")
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .background(Color.black)
    }
}
#endif
