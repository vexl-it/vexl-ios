//
//  TermsAndConditionsContent.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import UIKit

struct TermsAndConditionsContent: Identifiable {

    var id: String {
        title
    }

    struct Description {
        let text: String
        let font: UIFont
        let color: UIColor
    }

    let title: String
    let description: [Description]
    let attributedDescription: NSAttributedString

    init(title: String, description: [Description]) {
        self.title = title
        self.description = description
        let mutableAttributedString = NSMutableAttributedString()
        for element in description {
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: element.color,
                                                             .font: element.font]
            mutableAttributedString.append(.init(string: element.text, attributes: attributes))
        }
        self.attributedDescription = mutableAttributedString
    }

    static var termsContent: [TermsAndConditionsContent] {
        [
            .init(title: L.termsOfUseTermsOneTitle(), description: [.init(text: L.termsOfUseTermsOneDescription(),
                                                                          font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                                          color: R.color.gray3()!)]),
            .init(title: L.termsOfUseTermsTwoTitle(), description: [.init(text: L.termsOfUseTermsTwoDescription(),
                                                                          font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                                          color: R.color.gray3()!)]),
            .init(title: L.termsOfUseTermsThreeTitle(), description: [.init(text: L.termsOfUseTermsThreeDescriptionOne(),
                                                                            font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                                            color: R.color.gray3()!),
                                                                      .init(text: L.termsOfUseTermsThreeDescriptionTwo(),
                                                                            font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                                            color: UIColor(Appearance.Colors.whiteText)),
                                                                      .init(text: L.termsOfUseTermsThreeDescriptionThree(),
                                                                            font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                                            color: R.color.gray3()!)])
        ]
    }

    // TODO: - Add real content when available

    static var policyContent: [TermsAndConditionsContent] {
        [
            .init(title: L.termsOfUseTermsOneTitle(), description: [.init(text: L.termsOfUseTermsThreeDescriptionThree(),
                                                                          font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                                          color: R.color.gray3()!)]),
            .init(title: L.termsOfUseTermsTwoTitle(), description: [.init(text: L.termsOfUseTermsThreeDescriptionTwo(),
                                                                          font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                                          color: R.color.gray3()!)]),
            .init(title: L.termsOfUseTermsThreeTitle(), description: [.init(text: L.termsOfUseTermsThreeDescriptionOne(),
                                                                            font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                                            color: R.color.gray3()!)])
        ]
    }
}
