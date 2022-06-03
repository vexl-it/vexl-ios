//
//  LargeSolidButton.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import Cleevio
import SwiftUI

struct LargeSolidButton: View {

    enum Style {
        case main
        case secondary
        case red
        case redSecondary
        case custom(color: SolidButtonColor)

        var color: SolidButtonColor {
            switch self {
            case .main:
                return .main
            case .secondary:
                return .secondary
            case .red:
                return .red
            case .redSecondary:
                return .redSecondary
            case let .custom(color):
                return color
            }
        }
    }

    let title: String
    let font: Font
    let style: Style
    let isFullWidth: Bool
    @Binding var isEnabled: Bool
    let action: () -> Void

    var body: some View {
        SolidButton(Text(title),
                    iconImage: nil,
                    isEnabled: $isEnabled,
                    isLoading: .constant(false),
                    fullWidth: isFullWidth,
                    loadingViewScale: 1,
                    font: font,
                    colors: style.color,
                    dimensions: .largeButton,
                    action: action)
    }
}
