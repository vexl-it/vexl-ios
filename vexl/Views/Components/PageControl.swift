//
//  PageControl.swift
//  vexl
//
//  Created by Diego Espinoza on 5/08/22.
//

import SwiftUI

struct PageControl: View {
    let numberOfPages: Int
    let currentIndex: Int

    var body: some View {
        HStack {
            ForEach(0 ..< numberOfPages, id: \.self) { index in
                HLine(color: currentIndex >= index ? Appearance.Colors.black1 : Appearance.Colors.gray4,
                      height: Appearance.GridGuide.tinyPadding)
                    .frame(height: Appearance.GridGuide.tinyPadding)
                    .cornerRadius(Appearance.GridGuide.tinyPadding * 0.5)
                    .transition(.opacity)
            }
        }
    }
}

struct CirclePageControl: View {
    let numberOfPages: Int
    let currentIndex: Int

    private enum Constants {
        static let elementSize: CGFloat = 8
    }

    var body: some View {
        HStack(spacing: Appearance.GridGuide.tinyPadding) {
            ForEach((0..<numberOfPages), id: \.self) { index in
                Circle()
                    .foregroundColor(foregroundColor(for: index))
                    .frame(width: Constants.elementSize, height: Constants.elementSize)
            }
        }
    }

    private func foregroundColor(for index: Int) -> Color {
        currentIndex == index ?  Appearance.Colors.gray6 : Appearance.Colors.gray3
    }
}

struct ContinuousPageControl: UIViewRepresentable {
    @Binding var numberOfPages: Int
    @Binding var currentIndex: Int

    func makeUIView(context: Context) -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.currentPage = currentIndex
        pageControl.numberOfPages = numberOfPages
        pageControl.allowsContinuousInteraction = true
        return pageControl
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = currentIndex
    }
}
