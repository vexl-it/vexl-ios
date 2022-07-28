//
//  CLButton.swift
//
//  Created by Daniel Fernandez on 11/17/20.
//

import SwiftUI
import Combine

public struct CLButton: View {

    //MARK:- Variables

    var buttonTap: PassthroughSubject<Void, Never>
    var isLoading: Bool
    var isDisabled: Bool
    var text: String

    //MARK:- Button style

    var backgrondColor: Color = Color.blue
    var foregroundColor: Color = Color.white

    // MARK: - Initialization

    public init(buttonTap: PassthroughSubject<Void, Never>,
                text: String,
                isLoading: Bool = false,
                isDisabled: Bool = false) {
        self.buttonTap = buttonTap
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.text = text
    }


    public var body: some View {
        ZStack {
            Button {
                buttonTap.send(())
            } label: {
                Text(isLoading ? "" : text)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 56)
            }
            .disabled(isLoading || isDisabled)
            .buttonStyle(Style(backgrondColor: backgrondColor,
                               foregroundColor: foregroundColor,
                               isDisabled: isDisabled))

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
            }
        }
        .padding([.leading, .trailing, .bottom], 16)
    }
}

extension CLButton {
    struct Style: ButtonStyle {
        let backgrondColor: Color
        let foregroundColor: Color
        var isDisabled: Bool

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(foregroundColor)
                .background(backgrondColor)
                .opacity(configuration.isPressed || isDisabled ? 0.70 : 1.0)
                .cornerRadius(8)
                .animation(.default)
        }
    }
}
