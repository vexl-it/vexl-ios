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
    let padding: CGFloat
    let font: Font
    let style: Style
    let isFullWidth: Bool
    @Binding var isEnabled: Bool
    let action: () -> Void

    // swiftlint:disable:next function_default_parameter_at_end
    init(title: String,
         padding: CGFloat = .zero,
         font: Font,
         style: Style,
         isFullWidth: Bool,
         isEnabled: Binding<Bool>,
         action: @escaping () -> Void) {
        self.title = title
        self.padding = padding
        self.font = font
        self.style = style
        self.isFullWidth = isFullWidth
        self._isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        SolidButton(Text(title).padding(.horizontal, padding),
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
