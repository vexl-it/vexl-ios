//
//  CurrencySelect.swift
//  vexl
//
//  Created by Adam Salih on 24.06.2022.
//

import SwiftUI
import Combine

class DonateViewModel: BottomActionSheetViewModelProtocol {
    var title: String = L.userProfileDonateTitle()
    var primaryAction: BottomActionSheet<DonateContent>.Action = .init(title: L.userProfileDonateButtonDonate(), isDismissAction: true)
    var secondaryAction: BottomActionSheet<DonateContent>.Action? = .init(title: L.userProfileDonateButtonDismiss(), isDismissAction: true)
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: BottomActionSheet<DonateContent>.ColorScheme = .main
    var content: DonateContent {
        DonateContent(viewModel: self)
    }

    @Published var selectedCurrency: Currency!
    lazy var allCurrencies: [Currency] = Currency.allCases

    init() { }
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
            content: { model.content }
        )
        .background(Color.black.ignoresSafeArea())
        .previewDevice("iPhone 11")
    }
}
