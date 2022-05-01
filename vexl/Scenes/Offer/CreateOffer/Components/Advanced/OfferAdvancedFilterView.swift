//
//  OfferAdvancedFilterView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/04/22.
//

import SwiftUI

struct OfferAdvancedFilterView: View {

    @Binding var selectedTypeOptions: [OfferAdvancedTypeOption]
    @Binding var selectedFriendDegreeOption: OfferAdvancedFriendDegreeOption
    @State private var isExpanded = true

    var body: some View {
        VStack {
            HStack {
                Image(R.image.offer.mathAdvanced.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)

                Text(L.offerCreateAdvancedTitle())
                    .textStyle(.h3)
                    .foregroundColor(Appearance.Colors.whiteText)

                Spacer()

                Image(systemName: "chevron.down")
                    .foregroundColor(Appearance.Colors.gray3)
            }
            .onTapGesture {
                isExpanded.toggle()
            }

            if isExpanded {
                OfferAdvancedFilterTypeView(selectedOptions: $selectedTypeOptions)
                    .padding(.top, Appearance.GridGuide.mediumPadding2)

                OfferAdvanceFilterFriendDegreeView(selectedOption: $selectedFriendDegreeOption)
                    .padding(.top, Appearance.GridGuide.mediumPadding1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

#if DEBUG || DEVEL
struct OfferAdvancedFilterViewPreview: PreviewProvider {
    static var previews: some View {
        OfferAdvancedFilterView(selectedTypeOptions: .constant([]),
                                selectedFriendDegreeOption: .constant(.firstDegree))
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
