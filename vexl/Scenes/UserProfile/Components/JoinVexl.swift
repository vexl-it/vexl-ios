//
//  CurrencySelect.swift
//  vexl
//
//  Created by Adam Salih on 24.06.2022.
//

import SwiftUI
import Combine

class JoinVexlViewModel: BottomActionSheetViewModelProtocol {
    var imageName: String? = R.image.profile.joinVexlQR.name
    var title: String = L.userProfileJoinVexlTitle()
    var titleAlignment: Alignment = .center
    var primaryAction: BottomActionSheet<JoinVexlContent>.Action = .init(title: L.userProfileJoinVexlButtonTitle(), isDismissAction: true)
    var secondaryAction: BottomActionSheet<JoinVexlContent>.Action?
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: BottomActionSheet<JoinVexlContent>.ColorScheme = .main
    var content: JoinVexlContent {
        JoinVexlContent(viewModel: self)
    }

    init() { }
}

struct JoinVexlContent: View {
    @ObservedObject var viewModel: JoinVexlViewModel

    var body: some View {
        EmptyView()
    }
}

struct JoinVexlViewPreview: PreviewProvider {
    static var previews: some View {
        let model = JoinVexlViewModel()
        BottomActionSheet(
            title: model.title,
            primaryAction: model.primaryAction,
            secondaryAction: model.secondaryAction,
            colorScheme: model.colorScheme,
            content: { model.content }
        )
        .background(Color.black.ignoresSafeArea())
        .previewDevice("iPhone 11")
    }
}
