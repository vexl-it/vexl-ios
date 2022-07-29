//
//  ScrollableView.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 2/15/21.
//

import SwiftUI
import UIKit

struct ScrollableView<Content: View>: UIViewRepresentable {
    private let verticalOffset: Binding<CGFloat>
    private let currentPosition: Binding<PullUpViewPosition>
    private let content: UIView
    private let contentView = UIView()
    private let scrollView = UIScrollView()

    init(verticalOffset: Binding<CGFloat>,
         currentPosition: Binding<PullUpViewPosition>,
         @ViewBuilder content: () -> Content) {
        self.verticalOffset = verticalOffset
        self.currentPosition = currentPosition
        self.content = UIHostingController(rootView: content()).view
    }

    func makeUIView(context: Context) -> UIScrollView {
        content.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.addSubview(content)

        content.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, multiplier: 1).isActive = true

        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = context.coordinator
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    func makeCoordinator() -> ScrollableView.Coordinator {
        return Coordinator(scrollView: scrollView, verticalOffset: verticalOffset, currentPosition: currentPosition)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        private let scrollView: UIScrollView
        private let verticalOffset: Binding<CGFloat>
        private let currentPosition: Binding<PullUpViewPosition>
        

        init(scrollView: UIScrollView,
             verticalOffset: Binding<CGFloat>,
             currentPosition: Binding<PullUpViewPosition>) {
            self.scrollView = scrollView
            self.verticalOffset = verticalOffset
            self.currentPosition = currentPosition
            super.init()
            self.scrollView.delegate = self
        }

        // MARK: - UIScrollViewDelegate methods

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            let userIsSwipingUp = translation.y < 0

            if userIsSwipingUp && scrollView.contentOffset.y > 0 {
                handleOffsetWhenUserIsSwipingUp(scrollView: scrollView)
            } else {
                handleOffsetWhenUserIsSwipingDown(scrollView: scrollView)
            }
        }

        func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                       withVelocity velocity: CGPoint,
                                       targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            if currentPosition.wrappedValue != .full {
                targetContentOffset.pointee = scrollView.contentOffset // this is to avoid decelerating
            }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            guard verticalOffset.wrappedValue < 0 && currentPosition.wrappedValue == .full else { return }
            setFinalState(scrollView: scrollView)
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            guard !decelerate else { return }
            if currentPosition.wrappedValue == .full {
                if scrollView.contentOffset.y <= 0 {
                    setFinalState(scrollView: scrollView)
                }
            } else {
                setFinalState(scrollView: scrollView)
            }
        }

        // MARK: - Helper methods

        private func handleOffsetWhenUserIsSwipingUp(scrollView: UIScrollView) {
            if userDidntReachTop() {
                setOffset(scrollView: scrollView)
            }
        }

        private func handleOffsetWhenUserIsSwipingDown(scrollView: UIScrollView) {
            if userReachTop() {
                if scrollView.contentOffset.y < 0 && scrollView.isTracking {
                    setOffset(scrollView: scrollView)
                }
            } else {
                setOffset(scrollView: scrollView)
            }
        }

        private func userDidntReachTop() -> Bool {
            let offsetWhileDragging = currentPosition.wrappedValue.offset - verticalOffset.wrappedValue
            return offsetWhileDragging > PullUpViewPosition.full.offset
        }

        private func userReachTop() -> Bool {
            !userDidntReachTop()
        }

        private func setOffset(scrollView: UIScrollView) {
            verticalOffset.wrappedValue += scrollView.contentOffset.y
            scrollView.contentOffset.y = 0
        }

        private func setFinalState(scrollView: UIScrollView) {
            let verticalVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
            let userIsSwipingUp = verticalVelocity < 0
            let isFastSwipe = abs(verticalVelocity) > 200

            let topEdgeLocation = currentPosition.wrappedValue.offset - verticalOffset.wrappedValue
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
                    currentPosition.wrappedValue = positionAbove
                } else {
                    currentPosition.wrappedValue = positionBelow
                }
            } else {
                currentPosition.wrappedValue = closestPosition
            }

            verticalOffset.wrappedValue = 0
        }
    }
}
