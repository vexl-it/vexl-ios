//
//  StepperView.swift
//  Pods
//
//  Created by Diego on 25/01/22.
//

import SwiftUI

public struct CLStepperView: View {
    
    public enum Style {
        case minimal
        case colorful

        var decreaseBackgroundColor: Color {
            switch self {
            case .minimal:
                return Color.white
            case .colorful:
                return Color(.systemBlue)
            }
        }

        var decreaseForegroundColor: Color {
            switch self {
            case .minimal:
                return Color(.label)
            case .colorful:
                return Color.white
            }
        }

        var increaseBackgroundColor: Color {
            switch self {
            case .minimal:
                return Color.white
            case .colorful:
                return Color(.systemBlue)
            }
        }

        var increaseForegroundColor: Color {
            switch self {
            case .minimal:
                return Color(.label)
            case .colorful:
                return Color.white
            }
        }
    }

    @Binding var quantity: Int
    @Binding var isLoading: Bool

    let increaseButtonDisabled: Bool
    let backgroundColor: Color
    let increaseAction: () -> Void
    let decreaseAction: () -> Void
    let style: Style
    let loadingScale: CGFloat

    public init(
        increaseButtonDisabled: Bool,
        quantity: Binding<Int>,
        backgroundColor: Color,
        isLoading: Binding<Bool>,
        increaseAction: @escaping () -> Void,
        decreaseAction: @escaping () -> Void,
        style: Style = .colorful,
        loadingScale: CGFloat = 1.0
    ) {
        self.increaseButtonDisabled = increaseButtonDisabled
        self.backgroundColor = backgroundColor
        self.increaseAction = increaseAction
        self.decreaseAction = decreaseAction
        self.style = style
        self.loadingScale = loadingScale
        self._quantity = quantity
        self._isLoading = isLoading
    }

    public var body: some View {
        GeometryReader { geometry in
            HStack {
                Button(action: decreaseAction, label: {
                    RoundedRectangle(cornerRadius: 8)
                        .style(
                            withStroke: Color(.systemBlue),
                            lineWidth: style == .minimal ? 2 : 0,
                            fill: style.decreaseBackgroundColor
                        )
                        .frame(maxWidth: geometry.size.height)
                        .overlay(
                            Image(systemName: "minus")
                                .foregroundColor(style.decreaseForegroundColor)
                        )
                })
                .disabled(isLoading)

                Spacer()
                if isLoading {
                    LoadingView(scale: loadingScale)
                        .frame(width: 50, height: 10)
                } else {
                    Text("\(quantity)")
                        .font(.body)
                }
                Spacer()

                Button(action: increaseAction, label: {
                    RoundedRectangle(cornerRadius: 8)
                        .style(
                            withStroke: Color(.systemBlue),
                            lineWidth: style == .minimal ? 2 : 0,
                            fill: style.increaseBackgroundColor
                        )
                        .frame(maxWidth: geometry.size.height)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(style.increaseForegroundColor.opacity(increaseButtonDisabled ? 0.4 : 1))
                        )
                })
                .disabled(increaseButtonDisabled || isLoading)
            }
            .background(backgroundColor)
        }
    }
}
