//
//  RefreshContainer.swift
//  vexl
//
//  Created by Diego Espinoza on 27/07/22.
//

import SwiftUI

struct RefreshContainer<Content: View>: View {
    let topPadding: CGFloat
    @Binding var isRefreshing: Bool
    let content: () -> Content

    var body: some View {
        ZStack(alignment: .top) {
            content()

            RefreshControlView(
                topPadding: topPadding,
                isRefreshing: $isRefreshing
            )
        }
    }
}

struct RefreshControlView: View {
    let topPadding: CGFloat
    @Binding var isRefreshing: Bool
    @State private var showRefresh = false
    static let coordinateSpace: String = "refresh"

    var shouldShowProgressRefresh: Bool {
        showRefresh || isRefreshing
    }
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .named(Self.coordinateSpace)).minY > 130 {
                Color.clear
                    .onAppear {
                        showRefresh = true
                    }
            }

            if geometry.frame(in: .named(Self.coordinateSpace)).minY < 100, showRefresh {
                Color.clear
                    .onAppear {
                        if !isRefreshing {
                            isRefreshing = true
                            showRefresh = false
                        }
                    }
            }

            ZStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Appearance.Colors.whiteText))
                    .opacity(shouldShowProgressRefresh ? 1 : 0)
                    .animation(.easeInOut, value: shouldShowProgressRefresh)
            }
            .frame(width: geometry.size.width)
        }
        .offset(y: topPadding)
    }
}
