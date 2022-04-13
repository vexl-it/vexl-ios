//
//  BuySellFilterView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

struct BuySellFilterView: View {

    var body: some View {
        HStack(spacing: Appearance.GridGuide.smallPadding) {
            FilterButton(title: "Revolut") {
                print("1")
            }

            FilterButton(title: "up to 10K") {
                print("1")
            }

            FilterButton(title: "▽") {
                print("1")
            }

            Spacer()

            Button("+") {
                print("1")
            }
            .textStyle(.h3)
            .foregroundColor(Appearance.Colors.green5)
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background(Appearance.Colors.green1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .padding(.horizontal, Appearance.GridGuide.point)
    }
}

extension BuySellFilterView {

    private struct FilterButton: View {

        var title: String
        var action: () -> Void

        var body: some View {
            Button(title) {
                action()
            }
            .foregroundColor(Appearance.Colors.gray3)
            .padding(Appearance.GridGuide.point)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}
