//
//  UserOfferAttributedText.swift
//  vexl
//
//  Created by Diego Espinoza on 15/08/22.
//

import SwiftUI

struct UserOfferTypeAttributedText: View {

    let username: String
    let offerType: OfferType?

    private var attributedString: NSAttributedString {
        let string = NSMutableAttributedString(string: username,
                                               attributes: [.font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                            .foregroundColor: UIColor(Appearance.Colors.whiteText)])
        if let offerType = offerType {
            string.append(NSAttributedString(string: offerType == .buy ? L.marketplaceDetailUserBuy("") : L.marketplaceDetailUserSell("") ,
                                             attributes: [.font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                          .foregroundColor: offerType == .buy ? UIColor(Appearance.Colors.green100) :
                                                                                                UIColor(Appearance.Colors.pink100)]))
        }

        return string
    }

    var body: some View {
        AttributedText(attributedText: attributedString)
    }
}
