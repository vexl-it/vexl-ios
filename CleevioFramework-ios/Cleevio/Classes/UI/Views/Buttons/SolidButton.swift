//
//  SolidButton.swift
//  CleevioUI
//
//  Created by Diego on 6/01/22.
//

import SwiftUI
import UIKit

public struct SolidButton<Label>: View where Label: View {
    @Binding var isEnabled: Bool
    @Binding var isLoading: Bool
    
    private let textColor: Color
    private let disabledTextColor: Color
    private let backgroundColor: Color
    private let disabledBackgroundColor: Color
    private let iconTint: Color?
    private let loadingColor: Color
    private let disabledBackgroundOpacity: Double
    
    private let height: CGFloat
    private let fullWidth: Bool
    private let cornerRadius: CGFloat
    private let iconSize: CGSize
    private let iconPadding: CGFloat

    private let label: Label
    private let iconImage: Image?
    private let loadingViewScale: CGFloat
    private let buttonFont: Font
    let action: () -> Void

    public init(
        _ label: Label,
        iconImage: Image? = nil,
        isEnabled: Binding<Bool> = .constant(true),
        isLoading: Binding<Bool> = .constant(false),
        fullWidth: Bool = true,
        loadingViewScale: CGFloat = 1,
        font: Font = Font.system(.body),
        colors: SolidButtonColor = .default,
        dimensions: SolidButtonDimension = .default,
        action: @escaping () -> Void
    ) {
        self.textColor = colors.textColor
        self.disabledTextColor = colors.disabledTextColor
        self.iconTint = colors.iconTint
        self.backgroundColor = colors.backgroundColor
        self.disabledBackgroundColor = colors.disabledBackgroundColor
        self.loadingColor = colors.loadingColor
        self.disabledBackgroundOpacity = colors.disabledBackgroundOpacity
        
        self.cornerRadius = dimensions.cornerRadius
        self.height = dimensions.height
        self.iconSize = dimensions.iconSize
        self.iconPadding = dimensions.iconPadding
        
        self.action = action
        self.label = label
        self.iconImage = iconImage
        self.buttonFont = font
        
        self.fullWidth = fullWidth
        self.loadingViewScale = loadingViewScale
        self._isEnabled = isEnabled
        self._isLoading = isLoading
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            if isLoading {
                LoadingView(scale: loadingViewScale, circleColor: loadingColor)
                    .background(disabledBackgroundColor)
                    .cornerRadius(cornerRadius)
                    .frame(height: height)
            } else {
                Button(action: action, label: {
                    label
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .modifier(ViewWidthModifier(fullWidth: fullWidth))
                        .frame(height: height)
                })
                .buttonStyle(
                    SolidButtonStyle(
                        isEnabled: $isEnabled,
                        textColor: textColor,
                        disabledTextColor: disabledTextColor,
                        backgroundColor: backgroundColor,
                        disabledBackgroundColor: disabledBackgroundColor,
                        disabledBackgroundOpacity: disabledBackgroundOpacity,
                        cornerRadius: cornerRadius
                    )
                )
                .font(buttonFont)
                .disabled(!isEnabled || isLoading)
            }

            if let iconImage = iconImage, !isLoading {
                iconImage
                    .foregroundColor(iconTint)
                    .frame(width: iconSize.width, height: iconSize.height)
                    .padding(iconPadding)
            }
        }
    }
}

private struct SolidButtonStyle: ButtonStyle {
    @Binding var isEnabled: Bool
    let textColor: Color
    let disabledTextColor: Color
    let backgroundColor: Color
    let disabledBackgroundColor: Color
    let disabledBackgroundOpacity: Double
    let cornerRadius: CGFloat

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? textColor: disabledTextColor)
            .background(isEnabled ? backgroundColor : disabledBackgroundColor.opacity(disabledBackgroundOpacity))
            .cornerRadius(cornerRadius)
    }
}
