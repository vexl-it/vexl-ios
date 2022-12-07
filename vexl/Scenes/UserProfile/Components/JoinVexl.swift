//
//  CurrencySelect.swift
//  vexl
//
//  Created by Adam Salih on 24.06.2022.
//

import SwiftUI
import Combine

class JoinVexlViewModel: BottomActionSheetViewModelProtocol {

    typealias JoinVexlBottomSheet = BottomActionSheet<JoinVexlContent, EmptyView>

    var imageName: String? = R.image.profile.joinVexlQR.name
    var title: String = L.userProfileJoinVexlTitle()
    var titleAlignment: Alignment = .center
    var primaryAction: JoinVexlBottomSheet.Action = .init(title: L.userProfileJoinVexlButtonTitle(), isDismissAction: true)
    var secondaryAction: JoinVexlBottomSheet.Action?
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: JoinVexlBottomSheet.ColorScheme = .main
    var content: JoinVexlContent? {
        JoinVexlContent(viewModel: self)
    }
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
            imageView: { nil },
            content: { model.content },
            imageHeight: Appearance.GridGuide.bottomSheetImageDefaultHeight
        )
        .background(Color.black.ignoresSafeArea())
        .previewDevice("iPhone 11")
    }
}
