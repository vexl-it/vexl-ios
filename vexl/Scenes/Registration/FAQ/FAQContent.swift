//
//  FAQContent.swift
//  vexl
//
//  Created by Diego Espinoza on 5/08/22.
//

import Foundation
import UIKit

struct FAQContent: Identifiable {

    var id: String {
        title
    }

    struct Description {
        let text: String
        let font: UIFont
        let color: UIColor
    }

    let title: String
    let imageName: String
    let description: [Description]
    let attributedDescription: NSAttributedString

    init(title: String, imageName: String, description: [Description]) {
        self.title = title
        self.imageName = imageName
        self.description = description
        let mutableAttributedString = NSMutableAttributedString()
        for element in description {
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: element.color,
                                                             .font: element.font]
            mutableAttributedString.append(.init(string: element.text, attributes: attributes))
        }
        self.attributedDescription = mutableAttributedString
    }

    static var content: [FAQContent] {
        [
            .init(title: L.faqScene1Title(), imageName: R.image.faq1.name, description: [.init(text: L.faqScene1Description(),
                                                                 font: Appearance.TextStyle.paragraphSmall.font,
                                                                 color: R.color.gray3()!)]),
            .init(title: L.faqScene2Title(), imageName: R.image.faq2.name, description: [.init(text: L.faqScene2Description(),
                                                                 font: Appearance.TextStyle.paragraphSmall.font,
                                                                 color: R.color.gray3()!)]),
            .init(title: L.faqScene3Title(), imageName: R.image.faq3.name, description: [.init(text: L.faqScene3Description(),
                                                                 font: Appearance.TextStyle.paragraphSmall.font,
                                                                 color: R.color.gray3()!)]),
            .init(title: L.faqScene4Title(), imageName: R.image.faq4.name, description: [.init(text: L.faqScene4Description(),
                                                                 font: Appearance.TextStyle.paragraphSmall.font,
                                                                 color: R.color.gray3()!)]),
            .init(title: L.faqScene5Title(), imageName: R.image.faq5.name, description: [.init(text: L.faqScene5Description(),
                                                                 font: Appearance.TextStyle.paragraphSmall.font,
                                                                 color: R.color.gray3()!)]),
            .init(title: L.faqScene6Title(), imageName: R.image.faq6.name, description: [.init(text: L.faqScene6Description(),
                                                                 font: Appearance.TextStyle.paragraphSmall.font,
                                                                 color: R.color.gray3()!)]),
            .init(title: L.faqScene7Title(), imageName: R.image.faq7.name, description: [.init(text: L.faqScene7Description1(),
                                                                 font: Appearance.TextStyle.paragraphSmall.font,
                                                                 color: R.color.gray3()!),
                                                           .init(text: L.faqScene7Description2(),
                                                                 font: Appearance.TextStyle.paragraphSmallBold.font,
                                                                 color: R.color.black1()!),
                                                           .init(text: L.faqScene7Description3(),
                                                                 font: Appearance.TextStyle.paragraphSmall.font,
                                                                 color: R.color.gray3()!)])
        ]
    }
}
