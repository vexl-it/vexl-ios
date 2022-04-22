//
//  OfferAdvancedFilterView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/04/22.
//

import SwiftUI

struct OfferAdvancedFilterView: View {

    @State var isExpanded = true

    var body: some View {
        VStack {
            HStack {
                Image(R.image.offer.mathAdvanced.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)

                Text("Advanced")
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
                OfferAdvancedFilterTypeView()
                    .padding(.top, Appearance.GridGuide.mediumPadding2)

                OfferAdvancedFilterFriendView()
                    .padding(.top, Appearance.GridGuide.mediumPadding1)

                OfferAdvanceFilterFriendDegreeView()
                    .padding(.top, Appearance.GridGuide.mediumPadding1)
            }
        }
        .animation(.easeInOut(duration: 0.25))
    }
}

struct OfferAdvancedFilterTypeView: View {

    enum Option {
        case lightning, onChain

        var title: String {
            switch self {
            case .lightning:
                return "Lightning"
            case .onChain:
                return "On Chain"
            }
        }
    }

    @State var selectedOption: Option = .lightning
    let options: [Option] = [.lightning, .onChain]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Type")
                    .textStyle(.paragraph)

                Spacer()

                Image(systemName: "arrow.clockwise")
            }
            .foregroundColor(Appearance.Colors.gray3)

            SingleOptionPickerView(selectedOption: $selectedOption,
                                   options: options,
                                   content: { option in
                Text(option.title)
            },
                                   action: { option in
                print(option.title)
            })
        }
    }
}

struct OfferAdvancedFilterFriendView: View {

    enum Option {
        case all, phone, facebook

        var title: String {
            switch self {
            case .all:
                return "Any"
            case .phone:
                return "Contact List"
            case .facebook:
                return "Facebook"
            }
        }
    }

    @State var selectedOption: Option = .all
    let options: [Option] = [.all, .phone, .facebook]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Friend source")
                    .textStyle(.paragraph)

                Spacer()

                Image(systemName: "arrow.clockwise")
            }
            .foregroundColor(Appearance.Colors.gray3)

            SingleOptionPickerView(selectedOption: $selectedOption,
                                   options: options,
                                   content: { option in
                Text(option.title)
            },
                                   action: { option in
                print(option.title)
            })
        }
    }
}

struct OfferAdvanceFilterFriendDegreeView: View {

    enum Option {
        case firstDegree
        case secondDegree

        var degree: Int {
            switch self {
            case .firstDegree:
                return 1
            case .secondDegree:
                return 2
            }
        }

        var title: String {
            switch self {
            case .firstDegree:
                return "First Degree"
            case .secondDegree:
                return "Second Degree"
            }
        }
    }

    @State var selectedOption: Option = .firstDegree
    let options: [Option] = [.firstDegree, .secondDegree]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Friend level")
                    .textStyle(.paragraph)

                Spacer()

                Image(systemName: "arrow.clockwise")
            }
            .foregroundColor(Appearance.Colors.gray3)

            SingleOptionPickerView(selectedOption: $selectedOption,
                                   options: options,
                                   content: { option in
                Text(option.title)
                    .frame(maxWidth: .infinity)
            },
                                   action: { option in
                print(option.title)
            })
        }
    }
}

#if DEBUG || DEVEL
struct OfferAdvancedFilterViewPreview: PreviewProvider {
    static var previews: some View {
        OfferAdvancedFilterView()
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}
#endif
