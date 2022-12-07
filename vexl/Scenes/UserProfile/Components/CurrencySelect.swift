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

    typealias CurrencySelectBottomSheet = BottomActionSheet<CurrencySelectContent, EmptyView>

    var title: String = L.userProfileCurrencyTitle()
    var primaryAction: CurrencySelectBottomSheet.Action
    var secondaryAction: CurrencySelectBottomSheet.Action?
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: CurrencySelectBottomSheet.ColorScheme = .main
    var content: CurrencySelectContent? {
        CurrencySelectContent(viewModel: self)
    }

    @Published var selectedCurrency: Currency!
    lazy var allCurrencies: [Currency] = Currency.allCases

    init(isOnboarding: Bool = false) {
        primaryAction = .init(title: isOnboarding ? L.generalSave() : L.userProfileCurrencyDismissButton(),
                              isDismissAction: true)
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
                    RadioButton(isChecked: isSelected)
                        .padding(.horizontal, Appearance.GridGuide.tinyPadding)
                    Text(currency.title)
                        .textStyle(.paragraph)
                        .foregroundColor(isSelected ? Appearance.Colors.black1 : Appearance.Colors.gray4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: Appearance.GridGuide.baseHeight)
                .padding(.horizontal, Appearance.GridGuide.tinyPadding)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.select(currency: currency)
                }
            }
        }
    }
}
