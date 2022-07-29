//
//  PullUpScrollableView.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 2/15/21.
//

import SwiftUI

enum UIProperties {
    static let rectangleHeight: CGFloat = 5
    static let paddingForRectanglePullUp: CGFloat = 10
}

public struct PullUpScrollableView<Content: View>: View {
    private let content: Content
    @State private var verticalOffset: CGFloat = 0
    @State private var currentPosition: PullUpViewPosition
    @GestureState private var dragState: DragState = .inactive

    public init(initialPosition: PullUpViewPosition,
                @ViewBuilder content: () -> Content) {
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
                                currentPosition = .bottom
                            }
                    )

                VStack(spacing: UIProperties.paddingForRectanglePullUp) {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 40, height: UIProperties.rectangleHeight)
                        .cornerRadius(3)
                        .opacity(0.1)

                    ScrollableView(verticalOffset: $verticalOffset, currentPosition: $currentPosition) {
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
        let translation = dragState.isDragging ? (dragState.translation.height * -1) : verticalOffset
        let offsetWhileDragging = currentPosition.offset - translation
        let didUserReachTop = offsetWhileDragging <= PullUpViewPosition.full.offset
        return didUserReachTop ? PullUpViewPosition.full.offset : offsetWhileDragging
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let verticalVelocity = drag.predictedEndLocation.y - drag.location.y
        let userIsSwipingUp = verticalVelocity < 0
        let isFastSwipe = abs(verticalVelocity) > 200

        let topEdgeLocation = currentPosition.offset + drag.translation.height
        let positionAbove: PullUpViewPosition
        let positionBelow: PullUpViewPosition
        let closestPosition: PullUpViewPosition

        if topEdgeLocation <= PullUpViewPosition.middle.offset {
            positionAbove = .full
            positionBelow = .middle
        } else {
            positionAbove = .middle
            positionBelow = .bottom
        }

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

        guard offsetWhileDragging > PullUpViewPosition.full.offset else { return 0.5 }

        let progressDistance = PullUpViewPosition.middle.offset - offsetWhileDragging
        let span = PullUpViewPosition.middle.offset - PullUpViewPosition.full.offset
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
