//
//  RangePickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct RangePickerView: View {
    let currency: Currency
    @Binding var currentValue: ClosedRange<Int>
    let sliderBounds: ClosedRange<Int>

    var minValue: String {
        currency.formattedCurrency(amount: currentValue.lowerBound)
    }

    var maxValue: String {
        currency.formattedCurrency(amount: currentValue.upperBound)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.mediumPadding2) {
            RangeSliderView(value: $currentValue, bounds: sliderBounds)
                .padding(.horizontal, Appearance.GridGuide.padding)
                .padding(.vertical, Appearance.GridGuide.mediumPadding2)
        }
        .padding()
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    private struct RangeSliderView: View {

        private let bigThumbSize = CGSize(width: 38, height: 38)
        private let smallThumbSize = CGSize(width: 30, height: 30)

        @Binding var currentValue: ClosedRange<Int>
        let sliderBounds: ClosedRange<Int>
        let displayText = false

        public init(value: Binding<ClosedRange<Int>>, bounds: ClosedRange<Int>) {
            self._currentValue = value
            self.sliderBounds = bounds
        }

        var body: some View {

            // TODO: - update from geometry to readsize

            GeometryReader { geometry in
                sliderView(sliderSize: geometry.size)
            }
        }

        @ViewBuilder private func sliderView(sliderSize: CGSize) -> some View {
            let sliderViewYCenter = sliderSize.height / 2
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Appearance.Colors.gray2)
                    .frame(height: 4)

                ZStack {
                    let sliderBoundDifference = sliderBounds.count
                    let stepWidthInPixel = CGFloat(sliderSize.width) / CGFloat(sliderBoundDifference)

                    // Calculate Left Thumb initial position
                    let leftThumbLocation: CGFloat = $currentValue.wrappedValue.lowerBound == Int(sliderBounds.lowerBound)
                        ? 0
                        : CGFloat($currentValue.wrappedValue.lowerBound - Int(sliderBounds.lowerBound)) * stepWidthInPixel

                    // Calculate right thumb initial position
                    let rightThumbLocation = CGFloat($currentValue.wrappedValue.upperBound) * stepWidthInPixel

                    // Path between both handles
                    lineBetweenThumbs(from: CGPoint(x: leftThumbLocation, y: sliderViewYCenter),
                                      to: CGPoint(x: rightThumbLocation, y: sliderViewYCenter))

                    // Left Thumb Handle
                    let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
                    thumbView(position: leftThumbPoint, value: Int($currentValue.wrappedValue.lowerBound))
                        .highPriorityGesture(DragGesture().onChanged { dragValue in
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(max(0, dragLocation.x), sliderSize.width)

                            let newValue = Int(sliderBounds.lowerBound) + Int(xThumbOffset / stepWidthInPixel)

                            // Stop the range thumbs from colliding each other
                            if newValue < $currentValue.wrappedValue.upperBound {
                                $currentValue.wrappedValue = newValue...$currentValue.wrappedValue.upperBound
                            }
                        })

                    // Right Thumb Handle
                    thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: $currentValue.wrappedValue.upperBound)
                        .highPriorityGesture(DragGesture().onChanged { dragValue in
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(max(CGFloat(leftThumbLocation), dragLocation.x), sliderSize.width)

                            var newValue = Int(xThumbOffset / stepWidthInPixel) // convert back the value bound
                            newValue = min(newValue, Int(sliderBounds.upperBound))

                            // Stop the range thumbs from colliding each other
                            if newValue > $currentValue.wrappedValue.lowerBound {
                                $currentValue.wrappedValue = $currentValue.wrappedValue.lowerBound...newValue
                            }
                        })
                }
            }
        }

        @ViewBuilder func lineBetweenThumbs(from startPoint: CGPoint, to endPoint: CGPoint) -> some View {
            Path { path in
                path.move(to: startPoint)
                path.addLine(to: endPoint)
            }.stroke(Appearance.Colors.whiteText, lineWidth: 4)
        }

        @ViewBuilder func thumbView(position: CGPoint, value: Int) -> some View {
            ZStack {
                if displayText {
                    Text("Text for thumb goes here")
                }

                Circle()
                    .frame(size: bigThumbSize)
                    .foregroundColor(Appearance.Colors.whiteText)

                Circle()
                    .stroke(lineWidth: 3)
                    .frame(size: smallThumbSize)
            }
            .position(x: position.x, y: position.y)
        }
    }
}

#if DEBUG || DEVEL
struct RangePickerViewPreview: PreviewProvider {
    static var previews: some View {
        RangePickerView(currency: .usd,
                        currentValue: .constant(3...8),
                        sliderBounds: 1...10)
            .frame(height: 200)
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
