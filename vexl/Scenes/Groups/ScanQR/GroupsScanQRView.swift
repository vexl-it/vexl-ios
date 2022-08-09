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
                CameraScannerView()
                    .interval(delay: viewModel.scanInterval)
                    .onScan { code in
                        viewModel.action.send(.codeScan(code: code))
                    }
                    .edgesIgnoringSafeArea(.all)

                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(Color.black)
                    .opacity(0.8)
                    .mask(cutoutMask(width: min(300, UIScreen.main.width * 0.75))
                            .compositingGroup()
                            .luminanceToAlpha())
                    .edgesIgnoringSafeArea(.all)
            } else if viewModel.isCameraAvailable && !viewModel.showCamera {
                VStack {
                    Text(L.groupsEnterCameraDenied())
                        .foregroundColor(Appearance.Colors.whiteText)
                        .textStyle(.paragraphSemibold)
                        .padding(.bottom, Appearance.GridGuide.padding)
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
                Spacer()

                Button {
                    viewModel.action.send(.manualInputTap)
                } label: {
                    HStack {
                        Image(R.image.profile.qrManual.name)

                        Text(L.groupsEnterCode())
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
        .onAppear {
            viewModel.action.send(.cameraAccessRequest)
        }
    }

    @ViewBuilder
    private func cutoutMask(width: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)

            RoundedRectangle(cornerRadius: Appearance.GridGuide.buttonCorner)
                .foregroundColor(Color.black)
                .frame(width: width, height: width)
        }
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
