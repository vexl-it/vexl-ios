//
//  SolidButton+Helpers.swift
//  CleevioUI
//
//  Created by Diego on 10/01/22.
//

import SwiftUI

public struct SolidButtonColor {
    let textColor: Color
    let disabledTextColor: Color
    let backgroundColor: Color
    let disabledBackgroundColor: Color
    let iconTint: Color?
    let loadingColor: Color
    
    let disabledBackgroundOpacity: Double
    
    public init(textColor: Color,
                disabledTextColor: Color = .white,
                backgroundColor: Color,
                disabledBackgroundColor: Color? = nil,
                iconTint: Color?,
                disabledBackgroundOpacity: Double,
                loadingColor: Color = .white) {
        self.textColor = textColor
        self.disabledTextColor = disabledTextColor
        self.backgroundColor = backgroundColor
        self.iconTint = iconTint
        self.disabledBackgroundOpacity = disabledBackgroundOpacity
        self.loadingColor = loadingColor
        
        if let disabledBackgroundColor = disabledBackgroundColor {
            self.disabledBackgroundColor = disabledBackgroundColor
        } else {
            self.disabledBackgroundColor = backgroundColor.opacity(disabledBackgroundOpacity)
        }
    }
    
    public static var `default`: SolidButtonColor =
        SolidButtonColor(textColor: .white,
                         backgroundColor: Color(.systemBlue),
                         iconTint: nil,
                         disabledBackgroundOpacity: 0.4)
}

public struct SolidButtonDimension {
    let height: CGFloat
    let cornerRadius: CGFloat
    let iconSize: CGSize
    let iconPadding: CGFloat
    
    public init(height: CGFloat, cornerRadius: CGFloat, iconSize: CGSize, iconPadding: CGFloat) {
        self.height = height
        self.cornerRadius = cornerRadius
        self.iconSize = iconSize
        self.iconPadding = iconPadding
    }
    
    public static var `default` =
        SolidButtonDimension(height: 40,
                             cornerRadius: 8,
                             iconSize: CGSize(width: 15, height: 15),
                             iconPadding: 8)
}
