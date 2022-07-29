//
//  CLPinCode.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 2/11/21.
//

import SwiftUI
import Combine

public struct CLPinCode: View {
    var keyboardHeight: CGFloat?
    var maxDigits: Int
    var pinColoredCount: Int
    var color: Color
    var errorColor: Color
    var state: PinState
    var invalidAttempts: Int
    var keyTap: PassthroughSubject<Int, Never>
    var deleteTap: PassthroughSubject<Void, Never>

    public init(keyboardHeight: CGFloat? = nil,
                maxDigits: Int = 4,
                pinColoredCount: Int,
                color: Color,
                errorColor: Color,
                state: PinState,
                invalidAttempts: Int,
                keyTap: PassthroughSubject<Int, Never>,
                deleteTap: PassthroughSubject<Void, Never>) {
        self.keyboardHeight = keyboardHeight
        self.maxDigits = maxDigits
        self.pinColoredCount = pinColoredCount
        self.color = color
        self.errorColor = errorColor
        self.state = state
        self.invalidAttempts = invalidAttempts
        self.keyTap = keyTap
        self.deleteTap = deleteTap
    }

    public var body: some View {
        VStack {
            HStack(spacing: 20) {
                ForEach(0 ..< maxDigits, id: \.self) { index in
                    Circle()
                        .stroke(state == .missmatch ? errorColor : color, lineWidth: 1)
                        .background(
                            Circle()
                                .foregroundColor(
                                    index < pinColoredCount ? color : .clear
                                )
                        )
                        .frame(width: 13, height: 13)
                        .animation(nil)
                }
            }
            .modifier(Shake(animatableData: CGFloat(invalidAttempts)))
            .animation(Animation.easeInOut(duration: 0.4).delay(0.1))

            Spacer()

            CLKeyPad(keyTap: keyTap, deleteTap: deleteTap)
                .frame(maxWidth: .infinity, maxHeight: keyboardHeight != nil ? keyboardHeight! : .infinity)
        }
    }
}
