//
//  TermsAndConditionsView.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @ObservedObject var viewModel: TermsAndConditionsViewModel

    var body: some View {
        VStack {
            HeaderTitleView(title: L.termsOfUseTitle(), showsSeparator: false) {
                viewModel.action.send(.dismissTap)
            }

            faqView
                .padding(.top, Appearance.GridGuide.padding)

            sectionPicker
                .padding(.top, Appearance.GridGuide.padding)

            scrollView
                .padding(.top, Appearance.GridGuide.mediumPadding2)
                .padding(.horizontal, Appearance.GridGuide.point)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var faqView: some View {
        HStack(spacing: Appearance.GridGuide.smallPadding) {
            Image(systemName: "play.fill")
                .padding(Appearance.GridGuide.smallPadding)
                .background(Appearance.Colors.yellow100)
                .cornerRadius(Appearance.GridGuide.buttonCorner)

            Text(L.termsOfUseFaqButton())
                .foregroundColor(Appearance.Colors.yellow100)
        }
        .padding(Appearance.GridGuide.padding)
        .background(Appearance.Colors.yellow20)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
        .onTapGesture {
            viewModel.action.send(.faqTap)
        }
    }

    private var sectionPicker: some View {
        SingleOptionPickerView(selectedOption: $viewModel.currentSection,
                               options: TermsAndConditionsViewModel.Section.allCases,
                               content: { option in
            Text(option.label)
                .frame(maxWidth: .infinity)
        },
                               action: nil)
            .padding(Appearance.GridGuide.tinyPadding)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    private var scrollView: some View {
        ScrollView {
            AttributedText(attributedText: viewModel.currentContent)
                .multilineTextAlignment(.leading)
                .foregroundColor(Appearance.Colors.whiteText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEVEL || DEBUG

struct TermsAndConditionsViewPreview: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}

#endif
