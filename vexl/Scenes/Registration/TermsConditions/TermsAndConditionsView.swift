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
        Text("")
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
