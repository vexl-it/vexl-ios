//
//  LoadingIndicatorView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/03/22.
//

import SwiftUI
import Cleevio

struct AlertContainerView<Content: View>: View {
    @Binding var error: AlertError?
    var content: () -> Content

    var body: some View {
        content()
        .alert(item: $error) { alert in
            Alert(title: Text(alert.message), message: nil, dismissButton: Alert.Button.default(Text(L.generalOk())))
        }
    }
}

struct LoadingContainerView<Content: View>: View {
    var loading: Bool
    var content: () -> Content

    var body: some View {
        ZStack {
            if loading {
                LoadingIndicatorView()
                    .zIndex(2)
            }

            content()
                .zIndex(1)
        }
    }
}

struct LoadingIndicatorView: View {
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.25)
                .edgesIgnoringSafeArea(.all)

            VStack {
                LoadingView(circleColor: Color.black)
            }
            .frame(width: Appearance.GridGuide.largePadding2 * 2, height: Appearance.GridGuide.largePadding2 * 2)
            .background(Color.white)
            .cornerRadius(Appearance.GridGuide.point)
        }
    }
}
