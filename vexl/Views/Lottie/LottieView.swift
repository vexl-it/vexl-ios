//
//  LottieView.swift
//  vexl
//
//  Created by Diego Espinoza on 31/08/22.
//

import SwiftUI
import UIKit
import Lottie

enum LottiePlayMode {
    case play
    case pause(Time)
}

extension LottiePlayMode {
    enum Time {
        case start
        case end
        case exact(Double)
    }
}

struct LottieView: UIViewRepresentable {

    let animation: LottieAnimation
    let loopMode: LottieLoopMode
    let playMode: LottiePlayMode

    init(animation: LottieAnimation, loopMode: LottieLoopMode = .playOnce, playMode: LottiePlayMode = .play) {
        self.animation = animation
        self.loopMode = loopMode
        self.playMode = playMode
    }

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        let animationView = createAnimationView()
        setupAnimationView(animationView, withParentView: view)
        switch playMode {
        case .play:
            animationView.play()
        case .pause(let time):
            switch time {
            case .start:
                animationView.currentProgress = AnimationProgressTime(0)
            case .end:
                animationView.currentProgress = AnimationProgressTime(1)
            case .exact(let progress):
                animationView.currentProgress = AnimationProgressTime(progress)
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {}

    private func createAnimationView() -> AnimationView {
        let animationView = AnimationView()
        animationView.animation = Animation.named(animation.rawValue)
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.loopMode = self.loopMode
        return animationView
    }

    private func setupAnimationView(_ animationView: AnimationView, withParentView view: UIView) {
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
