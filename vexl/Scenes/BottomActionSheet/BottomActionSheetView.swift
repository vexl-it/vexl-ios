//
//  BottomActionSheetView.swift
//  vexl
//
//  Created by Adam Salih on 24.06.2022.
//

import SwiftUI
import Cleevio

struct BottomActionSheetView<ViewModel: BottomActionSheetViewModelProtocol>: View {

    @ObservedObject var viewModel: ViewModel

    @State var isVisible: Bool = false
    @State var dragOffset: Double = .zero

    private var onAppearAnimation: Animation {
        .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)
    }

    var body: some View {
        ZStack {
            dimmingView
            BottomActionSheet(
                imageName: viewModel.imageName,
                title: viewModel.title,
                titleAlignment: viewModel.titleAlignment,
                primaryAction: viewModel.primaryAction(dismiss: dismiss),
                secondaryAction: viewModel.secondaryAction(dismiss: dismiss),
                colorScheme: viewModel.colorScheme,
                content: { viewModel.content }
            )
            .offset(y: isVisible ? dragOffset : UIScreen.main.bounds.height)
            .onAppear { withAnimation(onAppearAnimation) { isVisible = true } }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height < 0 ? value.translation.height / 3 : value.translation.height
                    }
                    .onEnded { value in
                        withAnimation(onAppearAnimation) {
                            if value.predictedEndTranslation.height > UIScreen.main.bounds.height / 2 {
                                dismiss()
                            } else {
                                dragOffset = .zero
                            }
                        }
                    }
            )
        }
    }

    private var dimmingView: some View {
        Color.black
            .opacity(Appearance.dimmingViewOpacity)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                dismiss()
            }
    }

    private func dismiss() {
        withAnimation(onAppearAnimation) {
            isVisible = false
            viewModel.dismissPublisher.send()
        }
    }
}

struct BottomActionSheetViewPreview: PreviewProvider {
    static var previews: some View {
        BottomActionSheetView(viewModel: CurrencySelectViewModel())
            .background(
                Color.red.ignoresSafeArea()
            )
            .previewDevice("iPhone 11")
    }
}
