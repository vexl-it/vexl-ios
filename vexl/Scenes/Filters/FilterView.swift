//
//  FilterView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 23.05.2022.
//

import SwiftUI

struct FilterView: View {

    @ObservedObject var viewModel: FilterViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack {
                    VStack {
                        Group {
                            Text("Buy")
                                .textStyle(.h3)
                                .foregroundColor(Appearance.Colors.green1)
                            Text("Filter")
                                .textStyle(.h2)
                                .foregroundColor(Appearance.Colors.whiteText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: { viewModel.send(action: .dismissTap) }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Appearance.Colors.whiteText)
                            .frame(size: .init(width: 40, height: 40))
                    })
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Appearance.Colors.gray1)
                    )
                }
            }
        }
        .padding(Appearance.GridGuide.padding)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL
struct FilterViewPreview: PreviewProvider {
    static var previews: some View {
        FilterView(viewModel: .init())
    }
}
#endif
