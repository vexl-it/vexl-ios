//
//  LottieView.swift
//  vexl
//
//  Created by Diego Espinoza on 31/08/22.
//

import SwiftUI
import UIKit
import Lottie

struct LottieView: UIViewRepresentable {

    let name: String
    let loopMode: LottieLoopMode

    init(name: String, loopMode: LottieLoopMode = .playOnce) {
        self.name = name
        self.loopMode = loopMode
    }

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        let animationView = createAnimationView()
        setupAnimationView(animationView, withParentView: view)
        animationView.play()
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        uiView.subviews.forEach { $0.removeFromSuperview() }
        let animationView = createAnimationView()
        setupAnimationView(animationView, withParentView: uiView)
        animationView.play()
    }

    private func createAnimationView() -> AnimationView {
        let animationView = AnimationView()
        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.loopMode = .playOnce
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
