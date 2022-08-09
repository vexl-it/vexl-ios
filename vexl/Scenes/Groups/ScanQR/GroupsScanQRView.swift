//
//  GroupScanQRView.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import SwiftUI

struct GroupsScanQRView: View {

    @ObservedObject var viewModel: GroupsScanQRViewModel

    var body: some View {
        ZStack {
            if viewModel.isCameraAvailable && viewModel.showCamera {
                Text("Should show camera")
            } else if viewModel.isCameraAvailable && !viewModel.showCamera {
                VStack {
                    Text("Vexl has no access to the camera")
                        .foregroundColor(Appearance.Colors.whiteText)
                        .textStyle(.paragraphSemibold)
                        .padding(.bottom, Appearance.GridGuide.padding)

                    Text("Go to Settings and grant access to the camera functionality.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Appearance.Colors.gray3)
                        .textStyle(.paragraphSmall)
                        .padding(.horizontal, Appearance.GridGuide.largePadding2)
                }
            } else {
                Button(L.continue()) {
                    viewModel.action.send(.codeScan(code: viewModel.mockCode))
                }
                .textStyle(.paragraphSmallSemiBold)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding(Appearance.GridGuide.smallPadding)
                .background(Appearance.Colors.whiteText)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
            }

            VStack {
                Button {
                    viewModel.action.send(.manualInputTap)
                } label: {
                    HStack {
                        Image(R.image.profile.qrManual.name)

                        Text("Enter code manually")
                            .textStyle(.paragraphSmallSemiBold)
                            .foregroundColor(Appearance.Colors.primaryText)
                    }
                }
                .padding(Appearance.GridGuide.smallPadding)
                .background(Appearance.Colors.whiteText)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
                .padding(.bottom, Appearance.GridGuide.largePadding1)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL

struct GroupsScanQRViewPreview: PreviewProvider {
    static var previews: some View {
        GroupsScanQRView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}

#endif
