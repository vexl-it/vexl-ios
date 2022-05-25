//
//  FilterHeaderView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 24.05.2022.
//

import SwiftUI

struct FilterHeaderView: View {
    let filterType: String
    let resetAction: () -> Void
    let closeAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                titles

                resetFilterButton

                closeButton
            }
            .padding(.horizontal, Appearance.GridGuide.padding)

            Divider()
                .background(Appearance.Colors.gray4)
                .padding(.horizontal, -Appearance.GridGuide.padding)
        }
    }

    private var titles: some View {
        VStack {
            Group {
                Text(filterType)
                    .textStyle(.titleSmallBold)
                    .foregroundColor(Appearance.Colors.green1)
                Text(L.filterTitle())
                    .textStyle(.h2)
                    .foregroundColor(Appearance.Colors.whiteText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var resetFilterButton: some View {
        Button(action: resetAction, label: {
            Image(systemName: "arrow.clockwise")
                .rotationEffect(.degrees(90))
                .foregroundColor(Appearance.Colors.whiteText)
                .frame(size: Appearance.GridGuide.baseButtonSize)
        })
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Appearance.Colors.gray1)
        )
    }

    private var closeButton: some View {
        Button(action: closeAction, label: {
            Image(systemName: "xmark")
                .foregroundColor(Appearance.Colors.whiteText)
                .frame(size: Appearance.GridGuide.baseButtonSize)
        })
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Appearance.Colors.gray1)
        )
    }
}

#if DEBUG || DEVEL
struct FilterHeaderViewPreview: PreviewProvider {
    static var previews: some View {
        FilterHeaderView(filterType: "Buy", resetAction: {}, closeAction: {})
            .background(Color.black)
    }
}
#endif
