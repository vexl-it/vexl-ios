//
//  OfferAdvanceFilterGroupView.swift
//  vexl
//
//  Created by Adam Salih on 10.08.2022.
//

import SwiftUI

struct OfferAdvanceFilterGroupView: View {
    @Binding var groupRows: [[ManagedGroup]]
    @Binding var selectedGroup: ManagedGroup?

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
                        selectedGroup = nil
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
    func singleSelect(for options: [ManagedGroup?]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SingleOptionPickerView(
                selectedOption: $selectedGroup,
                options: options,
                backgroundTintColor: { option in option?.color },
                content: { group in
                    if let group = group {
                        if let logo = group.logo, let dataImage = UIImage(data: logo) {
                            Image(uiImage: dataImage)
                                .frame(maxWidth: cellSize, maxHeight: cellSize)
                                .aspectRatio(1, contentMode: .fill)
                                .fixedSize(horizontal: false, vertical: true)
                                .overlay(
                                    Image(systemName: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .offset(x: -10, y: -10)
                                        .opacity(selectedGroup == group ? 1 : 0)
                                )
                        } else {
                            if let char = group.name?.first {
                                Text(String(char))
                                    .textStyle(Appearance.TextStyle.ultraLargeTitle)
                                    .foregroundColor(Appearance.Colors.whiteText)
                                    .frame(maxWidth: cellSize, maxHeight: cellSize)
                                    .aspectRatio(1, contentMode: .fill)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .cornerRadius(Appearance.GridGuide.buttonCorner)
                                    .overlay(
                                        Image(systemName: "checkmark.circle.fill")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .offset(x: -10, y: -10)
                                            .opacity(selectedGroup == group ? 1 : 0)
                                    )
                            }
                        }
                    }
                },
                action: nil
            )
            .padding(.top, Appearance.GridGuide.point)
            HStack {
                Text(options.first??.name ?? "")
                    .textStyle(.paragraphSemibold)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Appearance.Colors.whiteText)
                Text(options.dropFirst().first??.name ?? "")
                    .textStyle(.paragraphSemibold)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Appearance.Colors.whiteText)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Appearance.GridGuide.smallPadding)
        }
    }
}
