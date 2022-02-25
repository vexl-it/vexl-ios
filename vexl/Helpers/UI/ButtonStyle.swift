//
//  ButtonStyle.swift
//  vexl
//
//  Created by Diego Espinoza on 18/02/22.
//

import SwiftUI
import UIKit
import Cleevio

extension SolidButtonDimension {
    static let largeButton = SolidButtonDimension(height: Appearance.GridGuide.largeButtonHeight,
                                                  cornerRadius: Appearance.GridGuide.buttonCorner,
                                                  iconSize: .zero,
                                                  iconPadding: 0)
}

extension SolidButtonColor {
     static let welcome = SolidButtonColor(textColor: Appearance.Colors.primaryText,
                                           disabledTextColor: Appearance.Colors.gray2,
                                           backgroundColor: Appearance.Colors.purple5,
                                           disabledBackgroundColor: Appearance.Colors.gray1,
                                           iconTint: nil,
                                           disabledBackgroundOpacity: 1)

    static let skip = SolidButtonColor(textColor: Appearance.Colors.gray3,
                                       backgroundColor: Appearance.Colors.gray1,
                                       iconTint: nil,
                                       disabledBackgroundOpacity: 1)
    
    static let verifying = SolidButtonColor(textColor: Appearance.Colors.primaryText,
                                            disabledTextColor: Appearance.Colors.primaryText,
                                            backgroundColor: Appearance.Colors.purple5,
                                            disabledBackgroundColor: Appearance.Colors.purple5,
                                            iconTint: nil,
                                            disabledBackgroundOpacity: 1)
    
    static let success = SolidButtonColor(textColor: Appearance.Colors.primaryText,
                                            disabledTextColor: Appearance.Colors.gray2,
                                            backgroundColor: Appearance.Colors.green5,
                                            disabledBackgroundColor: Appearance.Colors.gray1,
                                            iconTint: nil,
                                            disabledBackgroundOpacity: 1)
}
