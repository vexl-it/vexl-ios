//
//  TermsAndConditionsContent.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import UIKit

struct TermsAndConditionsContent {
    
    let text: String
    let attributedDescription: NSAttributedString
    
    init(text: String) {
        self.text = text
        self.attributedDescription = text.configureAttributedText()
    }
}
