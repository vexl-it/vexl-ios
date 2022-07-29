//
//  PullUpFlexibleScrollableView.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 2/17/21.
//

import SwiftUI

public struct PullUpFlexibleScrollableView<Content: View>: View {
    private let content: Content
    private let supportedPositions: [PullUpFlexiblePosition]
    @State private var verticalOffset: CGFloat = 0
    @State private var currentPosition: PullUpFlexiblePosition
    @GestureState private var dragState: DragState = .inactive

    public init(supportedPositions: [PullUpFlexiblePosition],
                initialPosition: PullUpFlexiblePosition,
                @ViewBuilder content: () -> Content) {
        self.supportedPositions = supportedPositions
        _currentPosition = State(initialValue: initialPosition)
        self.content = content()
    }

    public var body: some View {
        let drag = DragGesture()
            .updating($dragState) { value, state, transaction in
                state = .dragging(translation: value.translation)
            }
            .onEnded(onDragEnded)

        return GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(getOverlayOpacity()))
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(dragState.isDragging ? nil : .default)
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                let minPosition = PullUpFlexiblePosition.minPosition(from: supportedPositions)
                                currentPosition = minPosition
                            }
                    )

                VStack(spacing: UIProperties.paddingForRectanglePullUp) {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 40, height: UIProperties.rectangleHeight)
                        .cornerRadius(3)
                        .opacity(0.1)

                    FlexibleScrollableView(
                        supportedPositions: supportedPositions,
                        verticalOffset: $verticalOffset,
                        currentPosition: $currentPosition
                    ) {
                        self.content
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: getScrollViewHeight()
                    )

                    Spacer()
                }
                .padding(.top, UIProperties.paddingForRectanglePullUp)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 20)
                .offset(y: getOffset())
                .animation(dragState.isDragging ? nil : .interpolatingSpring(stiffness: 300, damping: 30))
                .gesture(drag)
            }
        }
    }

    private func getOffset() -> CGFloat {
        let topPositionOffset = PullUpFlexiblePosition.maxPosition(from: supportedPositions).offset
        let translation = dragState.isDragging ? (dragState.translation.height * -1) : verticalOffset
        let offsetWhileDragging = currentPosition.offset - translation
        let didUserReachTop = offsetWhileDragging <= topPositionOffset
        return didUserReachTop ? topPositionOffset : offsetWhileDragging
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let verticalVelocity = drag.predictedEndLocation.y - drag.location.y
        let userIsSwipingUp = verticalVelocity < 0
        let isFastSwipe = abs(verticalVelocity) > 200

        let topEdgeLocation = currentPosition.offset + drag.translation.height
        let positionAbove = PullUpFlexiblePosition.abovePosition(
            from: supportedPositions,
            currentPosition: currentPosition
        )
        let positionBelow = PullUpFlexiblePosition.belowPosition(
            from: supportedPositions,
            currentPosition: currentPosition
        )
        let closestPosition: PullUpFlexiblePosition

        if (topEdgeLocation - positionAbove.offset) < (positionBelow.offset - topEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }

        if isFastSwipe {
            if userIsSwipingUp {
                currentPosition = positionAbove
            } else {
                currentPosition = positionBelow
            }
        } else {
            currentPosition = closestPosition
        }
    }

    private func getOverlayOpacity() -> Double {
        let translation = dragState.isDragging ? (dragState.translation.height * -1) : verticalOffset
        let offsetWhileDragging = currentPosition.offset - translation
        let maxPositionOffset = PullUpFlexiblePosition.maxPosition(from: supportedPositions).offset

        guard offsetWhileDragging > maxPositionOffset else { return 0.5 }

        let middlePositionOffset = PullUpFlexiblePosition.middlePosition(from: supportedPositions).offset
        let progressDistance = middlePositionOffset - offsetWhileDragging
        let span = middlePositionOffset - maxPositionOffset
        let progress = progressDistance / span
        return progress <= 0 ? 0 : Double(progress) * 0.5
    }

    private func getScrollViewHeight() -> CGFloat {
        let translation = dragState.isDragging ? (dragState.translation.height * -1) : verticalOffset
        let offsetWhileDragging = currentPosition.offset - translation

        return UIScreen.main.bounds.height -
            offsetWhileDragging -
            UIProperties.rectangleHeight
    }
}
