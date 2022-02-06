//
//  UIView+.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit
import SnapKit

extension UIView {

    var safeArea: ConstraintBasicAttributesDSL {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.snp
        }

        return self.snp
    }
}
