//
//  OfferAmountTextField.swift
//  vexl
//
//  Created by Adam Salih on 13.09.2022.
//

import SwiftUI
import Combine
import Cleevio

typealias OfferAmountTextFieldViewModel = OfferAmountTextField.ViewModel

struct OfferAmountTextField: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if viewModel.currency.position == .left {
                    Text(viewModel.currency.sign)
                }
                IsFocusTextField(
                    placeholder: "",
                    keyboardType: .numberPad,
                    textColor: .white,
                    textStyle: .paragraphMedium,
                    text: $viewModel.text,
                    isEnabled: true,
                    isFocused: $viewModel.isFocused
                )
                if viewModel.currency.position == .right {
                    Text(viewModel.currency.sign)
                }
                Spacer()
            }
            .textStyle(.paragraphMedium)
            .frame(maxWidth: .infinity)
            .foregroundColor(Appearance.Colors.whiteText)
            .padding()
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

extension OfferAmountTextField {
    enum AmountRangeType {
        case min
        case max
    }

    class ViewModel: ObservableObject {
        let type: AmountRangeType
        @Published var currency: Currency = .usd
        @Published var text: String = ""
        @Published var isFocused: Bool = false
        @Published var currentRange: ClosedRange<Int> = 0...0
        @Published var sliderBounds: ClosedRange<Int> = 0...0

        var rangeSetter: (ClosedRange<Int>) -> Void

        private let cancelBag: CancelBag = .init()

        private var textToValue: Int {
            guard let value = Int(text) else {
                switch type {
                case .min:
                    return currentRange.lowerBound
                case .max:
                    return currentRange.upperBound
                }
            }
            return value
        }

        convenience init(type: AmountRangeType, offerPublisher: Published<Offer>.Publisher, rangeSetter: @escaping (ClosedRange<Int>) -> Void) {
            self.init(
                type: type,
                currentAmountRangePublisher: offerPublisher.map(\.currentAmountRange).eraseToAnyPublisher(),
                sliderBoundsPublisher: offerPublisher.map(\.amountRange).eraseToAnyPublisher(),
                currencyPublisher: offerPublisher.compactMap(\.currency).eraseToAnyPublisher(),
                rangeSetter: rangeSetter
            )
        }

        init(
            type: AmountRangeType,
            currentAmountRangePublisher: AnyPublisher<ClosedRange<Int>, Never>,
            sliderBoundsPublisher: AnyPublisher<ClosedRange<Int>, Never>,
            currencyPublisher: AnyPublisher<Currency, Never>,
            rangeSetter: @escaping (ClosedRange<Int>) -> Void
        ) {
            self.type = type
            self.rangeSetter = rangeSetter

            sliderBoundsPublisher
                .assign(to: &$sliderBounds)

            currentAmountRangePublisher
                .assign(to: &$currentRange)

            currencyPublisher
                .assign(to: &$currency)

            switch type {
            case .min:
                self.text = "\(self.currentRange.lowerBound)"
            case .max:
                self.text = "\(self.currentRange.upperBound)"
            }
            setupBindings()
        }

        func setupBindings() {
            $isFocused
                .filter { !$0 }
                .withUnretained(self)
                .sink { owner, _ in
                    let range: ClosedRange<Int> = {
                        switch owner.type {
                        case .min:
                            if owner.textToValue <= owner.currentRange.upperBound, owner.textToValue >= owner.sliderBounds.lowerBound {
                                return owner.textToValue...owner.currentRange.upperBound
                            }
                        case .max:
                            if owner.textToValue >= owner.currentRange.lowerBound, owner.textToValue <= owner.sliderBounds.upperBound {
                                return owner.currentRange.lowerBound...owner.textToValue
                            }
                        }
                        return owner.currentRange
                    }()
                    owner.rangeSetter(range)
                }
                .store(in: cancelBag)

            $currentRange
                .withUnretained(self)
                .sink(receiveValue: { owner, range in
                    switch owner.type {
                    case .min:
                        self.text = "\(range.lowerBound)"
                    case .max:
                        self.text = "\(range.upperBound)"
                    }
                })
                .store(in: cancelBag)
        }
    }
}
