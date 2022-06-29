//
//  BottomActionSheetViewModel.swift
//  vexl
//
//  Created by Adam Salih on 24.06.2022.
//

import SwiftUI
import Combine
import Cleevio

protocol BottomActionSheetViewModelProtocol: ObservableObject {
    associatedtype ContentView: View

    var imageName: String? { get }
    var title: String { get }
    var titleAlignment: Alignment { get }
    var primaryAction: BottomActionSheet<ContentView>.Action { get }
    var secondaryAction: BottomActionSheet<ContentView>.Action? { get }
    var dismissPublisher: PassthroughSubject<Void, Never> { get }
    var colorScheme: BottomActionSheet<ContentView>.ColorScheme { get }
    @ViewBuilder var content: ContentView { get }
}

extension BottomActionSheetViewModelProtocol {
    var imageName: String? { nil }
    var titleAlignment: Alignment { .leading }

    func primaryAction(dismiss: @escaping () -> Void) -> BottomActionSheet<ContentView>.Action {
        var action = primaryAction
        action.inject(dismissAction: dismiss)
        return action
    }

    func secondaryAction(dismiss: @escaping () -> Void) -> BottomActionSheet<ContentView>.Action? {
        var action = secondaryAction
        action?.inject(dismissAction: dismiss)
        return action
    }
}
