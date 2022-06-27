//
//  CurrencySelect.swift
//  vexl
//
//  Created by Adam Salih on 24.06.2022.
//

import SwiftUI
import Combine

class CurrencySelectViewModel: BottomActionSheetViewModelProtocol {
    @Inject var cryptocurrencyValueManager: CryptocurrencyValueManagerType

    var title: String = L.userProfileCurrencyTitle()
    var primaryAction: BottomActionSheet<CurrencySelectContent>.Action = .init(title: L.userProfileCurrencyDismissButton(), isDismissAction: true)
    var secondaryAction: BottomActionSheet<CurrencySelectContent>.Action?
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: BottomActionSheet<CurrencySelectContent>.ColorScheme = .main
    var content: CurrencySelectContent {
        CurrencySelectContent(viewModel: self)
    }

    @Published var selectedCurrency: Currency!
    lazy var allCurrencies: [Currency] = Currency.allCases

    init() {
        selectedCurrency = cryptocurrencyValueManager.selectedCurrency.value
    }

    func select(currency: Currency) {
        selectedCurrency = currency
        cryptocurrencyValueManager.select(currency: currency)
    }
}

struct CurrencySelectContent: View {
    @ObservedObject var viewModel: CurrencySelectViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.allCurrencies) { currency in
                HStack(spacing: Appearance.GridGuide.point) {
                    let isSelected = currency == viewModel.selectedCurrency
                    CheckBox(isChecked: isSelected)
                        .padding(.horizontal, Appearance.GridGuide.tinyPadding)
                    Text(currency.title)
                        .textStyle(.paragraph)
                        .foregroundColor(isSelected ? Appearance.Colors.black1 : Appearance.Colors.gray4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: Appearance.GridGuide.baseHeight)
                .padding(.horizontal, Appearance.GridGuide.tinyPadding)
                .onTapGesture {
                    viewModel.select(currency: currency)
                }
            }
        }
    }
}
