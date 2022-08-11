//
//  OfferAdvancedFilterView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/04/22.
//

import SwiftUI

struct OfferAdvancedFilterView: View {

    @Binding var selectedTypeOptions: [OfferAdvancedBTCOption]
    @Binding var selectedFriendDegreeOption: OfferFriendDegree

    @Binding var groupRows: [[ManagedGroup]]
    @Binding var selectedGroup: ManagedGroup?

    @State private var isExpanded = true

    var body: some View {
        VStack {
            HStack {
                Image(R.image.offer.mathAdvanced.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)

                Text(L.offerCreateAdvancedTitle())
                    .textStyle(.titleSemiBold)
                    .foregroundColor(Appearance.Colors.whiteText)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(Appearance.Colors.gray3)
            }
            .onTapGesture {
                isExpanded.toggle()
            }

            if isExpanded {
                OfferAdvancedFilterBTCNetworkView(selectedOptions: $selectedTypeOptions)
                    .padding(.top, Appearance.GridGuide.padding)

                OfferAdvanceFilterFriendDegreeView(selectedOption: $selectedFriendDegreeOption)
                    .padding(.top, Appearance.GridGuide.mediumPadding1)
                if !groupRows.isEmpty {
                    OfferAdvanceFilterGroupView(groupRows: $groupRows, selectedGroup: $selectedGroup)
                        .padding(.top, Appearance.GridGuide.mediumPadding1)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}


#if DEBUG || DEVEL
struct OfferAdvancedFilterViewPreview: PreviewProvider {
    static var previews: some View {
        OfferAdvancedFilterView(
                selectedTypeOptions: .constant([]),
                selectedFriendDegreeOption: .constant(.firstDegree),
                groupRows: .constant([]),
                selectedGroup: .constant(nil)
            )
            .previewDevice("iPhone 11")
            .background(Color.black)

        OfferAdvancedFilterView(
                selectedTypeOptions: .constant([]),
                selectedFriendDegreeOption: .constant(.firstDegree),
                groupRows: .constant([]),
                selectedGroup: .constant(nil)
            )
            .previewDevice("iPhone SE")
            .background(Color.black)
    }
}
#endif

