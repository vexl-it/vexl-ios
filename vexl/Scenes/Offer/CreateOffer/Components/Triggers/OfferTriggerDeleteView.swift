//
//  OfferTriggerDeleteView.swift
//  vexl
//
//  Created by Diego Espinoza on 12/06/22.
//

import SwiftUI

typealias OfferTriggerDeleteTimeUnit = OfferTriggerDeleteView.TimeUnit

struct OfferTriggerDeleteView: View {

    @Binding var time: String
    @Binding var timeUnit: TimeUnit

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            HStack {
                Text(L.offerCreateTriggerDelete())
                    .textStyle(.paragraphMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, Appearance.GridGuide.mediumPadding1)
            .foregroundColor(Appearance.Colors.gray3)

            HStack {
                TextField("", text: $time)
                    .multilineTextAlignment(.center)
                    .textStyle(.h3)
                    .foregroundColor(Appearance.Colors.yellow100)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: .infinity)

                VLine(color: Appearance.Colors.gray3,
                      width: 1)

                Menu {
                    ForEach(TimeUnit.allCases) { option in
                        Button(option.title) {
                            timeUnit = option
                        }
                    }
                } label: {
                    HStack {
                        Text(timeUnit.title)
                            .textStyle(.paragraphMedium)

                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(Appearance.Colors.gray4)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

extension OfferTriggerDeleteView {
    enum TimeUnit: Identifiable, CaseIterable {
        case days
        case weeks
        case months

        var id: TimeUnit { self }

        var title: String {
            switch self {
            case .days:
                return L.offerCreateTriggerDeleteDays()
            case .months:
                return L.offerCreateTriggerDeleteMonths()
            case .weeks:
                return L.offerCreateTriggerDeleteWeeks()
            }
        }
    }
}

#if DEBUG || DEVEL
struct OfferTriggerDeleteViewPreview: PreviewProvider {
    static var previews: some View {
        OfferTriggerDeleteView(time: .constant("30"),
                               timeUnit: .constant(.days))
            .background(Color.black)
            .frame(height: 125)
    }
}
#endif
