//
//  OfferSettingsProgressView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/09/22.
//

import SwiftUI

struct OfferSettingsProgressView: View {
    let currentValue: Int
    let maxValue: Int

    @State private var opacity: CGFloat = 0
    @State private var offset: CGFloat = .zero
    @State private var isVisible = false

    private var percentage: Int {
        let double = Double(currentValue) / Double(maxValue)
        return Int(double * 100)
    }

    private var progressText: String {
        if inProgress {
            return "for \(maxValue) vexlers"
        } else {
            return "Anonymously delivered to \(maxValue) vexlers"
        }
    }

    private var inProgress: Bool {
        currentValue < maxValue
    }

    var body: some View {
        VStack {
            //dimmingView
                //.opacity(isVisible ? Appearance.dimmingViewOpacity : 0)

            progress
                //.offset(y: isVisible ? .zero : UIScreen.main.bounds.height)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
//        .onTapGesture {
//            withAnimation {
//                isVisible = false
//            }
//        }
//        .onAppear {
//            withAnimation {
//                isVisible = true
//            }
//        }
    }

    private var dimmingView: some View {
        Color.black
            .opacity(Appearance.dimmingViewOpacity)
            .edgesIgnoringSafeArea(.all)
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.smallPadding) {
            Text("Encrypting your offer ...")
                .textStyle(.h2)
                .foregroundColor(Appearance.Colors.black1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            ProgressView(value: CGFloat(currentValue), total: CGFloat(maxValue))
                .progressViewStyle(
                    LinearProgressViewStyle(tint: Appearance.Colors.black1)
                )

            HStack {
                Text(progressText)
                    .foregroundColor(Appearance.Colors.black1)
                    .textStyle(.descriptionBold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if inProgress {
                    Text("\(percentage)% Done")
                        .foregroundColor(Appearance.Colors.gray3)
                        .textStyle(.description)
                }
            }
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            Text("Don’t shut down the app while encrypting. It can take several minutes.")
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
        .padding(.horizontal, Appearance.GridGuide.smallPadding)
    }
}

#if DEBUG || DEVEL

struct OfferSettingsProgressViewPreview: PreviewProvider {
    struct OfferSettingsTestView: View {
        var body: some View {
            VStack {
                Text("This is a test")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay(
                OfferSettingsProgressView(currentValue: 100, maxValue: 1_000)
            )
        }
    }

    static var previews: some View {
        OfferSettingsTestView()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .previewDevice("iPhone 11")
    }
}

#endif
