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
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> { get }
    var dismissPublisher: PassthroughSubject<Void, Never> { get }
    var colorScheme: BottomActionSheet<ContentView>.ColorScheme { get }
    @ViewBuilder var content: ContentView { get }
}

extension BottomActionSheetViewModelProtocol {
    var imageName: String? { nil }
    var titleAlignment: Alignment { .leading }
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> { .init() }

    func primaryAction(dismiss: @escaping (BottomActionSheetActionType) -> Void) -> BottomActionSheet<ContentView>.Action {
        var action = primaryAction
        action.type = .primary
        action.inject(dismissAction: dismiss)
        return action
    }

    func secondaryAction(dismiss: @escaping (BottomActionSheetActionType) -> Void) -> BottomActionSheet<ContentView>.Action? {
        var action = secondaryAction
        action?.type = .secondary
        action?.inject(dismissAction: dismiss)
        return action
    }
}
