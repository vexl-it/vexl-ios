//
//  CurrencySelect.swift
//  vexl
//
//  Created by Adam Salih on 24.06.2022.
//

import SwiftUI
import Combine

class DonateViewModel: BottomActionSheetViewModelProtocol {

    typealias DonateBottomSheet = BottomActionSheet<DonateContent, LottieView>

    var title: String = L.userProfileDonateTitle()
    var primaryAction: DonateBottomSheet.Action = .init(title: L.userProfileDonateButtonDonate(), isDismissAction: true)
    var secondaryAction: DonateBottomSheet.Action? = .init(title: L.userProfileDonateButtonDismiss(), isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: DonateBottomSheet.ColorScheme = .main
    var imageView: LottieView? {
        LottieView(animation: .donate, loopMode: .loop)
    }
    var content: DonateContent? {
        DonateContent(viewModel: self)
    }
}

struct DonateContent: View {
    @ObservedObject var viewModel: DonateViewModel

    var body: some View {
        Text(L.userProfileDonateDescription())
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
    }
}

struct DonateViewPreview: PreviewProvider {
    static var previews: some View {
        let model = DonateViewModel()
        BottomActionSheet(
            title: model.title,
            primaryAction: model.primaryAction,
            secondaryAction: model.secondaryAction,
            colorScheme: model.colorScheme,
            imageView: { nil },
            content: { model.content },
            imageHeight: Appearance.GridGuide.bottomSheetImageDefaultHeight
        )
        .background(Color.black.ignoresSafeArea())
        .previewDevice("iPhone 11")
    }
}
