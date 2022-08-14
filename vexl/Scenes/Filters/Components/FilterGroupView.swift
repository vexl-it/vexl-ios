//
//  FilterGroupView.swift
//  vexl
//
//  Created by Adam Salih on 12.08.2022.
//

import SwiftUI

struct FilterGroupView: View {
    @Binding var groupRows: [[ManagedGroup]]
    @Binding var selectedGroups: [ManagedGroup]

    private let cellSize: Double = (UIScreen.main.width - 10 - (6 * Appearance.GridGuide.padding)) / 2.0

    var body: some View {
        LazyVStack(alignment: .leading) {
            HStack {
                VStack {
                    Text(L.offerCreateAdvancedGroupTitle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textStyle(.paragraph)

                    Text(L.offerCreateAdvancedGroupDescription())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textStyle(.micro)
                }
                .foregroundColor(Appearance.Colors.gray3)

                Button(
                    action: {
                        selectedGroups = []
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(90))
                            .foregroundColor(Appearance.Colors.whiteText)
                            .frame(size: Appearance.GridGuide.baseButtonSize)
                    }
                )
            }
            .frame(maxWidth: .infinity)

            ForEach(Array(groupRows.enumerated()), id: \.offset) { groupRow in
                singleSelect(for: groupRow.element)
            }
        }
    }

    @ViewBuilder
    func singleSelect(for options: [ManagedGroup]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            MultipleOptionPickerView(
                selectedOptions: $selectedGroups,
                options: options ,
                content: { group in
                    if let group = group {
                        if let logo = group.logo, let dataImage = UIImage(data: logo) {
                            Image(uiImage: dataImage)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    Image(systemName: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .offset(x: -10, y: -10)
                                        .opacity(selectedGroups.contains(group) ? 1 : 0)
                                )
                        } else if let char = group.name?.first {
                            Text(String(char))
                                .textStyle(Appearance.TextStyle.ultraLargeTitle)
                                .foregroundColor(Appearance.Colors.whiteText)
                                .frame(maxWidth: cellSize, maxHeight: cellSize)
                                .aspectRatio(1, contentMode: .fill)
                                .cornerRadius(Appearance.GridGuide.buttonCorner)
                                .overlay(
                                    Image(systemName: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .offset(x: -10, y: -10)
                                        .opacity(selectedGroups.contains(group) ? 1 : 0)
                                )
                        }
                    }
                },
                action: nil
            )
            .padding(.top, Appearance.GridGuide.point)
            HStack {
                Text(options.first?.name ?? "")
                    .textStyle(.paragraphSemibold)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Appearance.Colors.whiteText)
                Text(options.dropFirst().first?.name ?? "")
                    .textStyle(.paragraphSemibold)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Appearance.Colors.whiteText)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Appearance.GridGuide.smallPadding)
        }
    }
}
