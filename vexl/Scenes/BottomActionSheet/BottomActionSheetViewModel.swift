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
    associatedtype ImageView: View

    var imageName: String? { get }
    var title: String { get }
    var titleAlignment: Alignment { get }
    var primaryAction: BottomActionSheet<ContentView, ImageView>.Action { get }
    var secondaryAction: BottomActionSheet<ContentView, ImageView>.Action? { get }
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> { get }
    var dismissPublisher: PassthroughSubject<Void, Never> { get }
    var colorScheme: BottomActionSheet<ContentView, ImageView>.ColorScheme { get }
    var imageView: ImageView? { get }
    var imageHeight: Double { get }
    @ViewBuilder var content: ContentView? { get }
}

extension BottomActionSheetViewModelProtocol {
    var imageName: String? { nil }
    var titleAlignment: Alignment { .leading }
    var imageView: ImageView? { nil }
    var imageHeight: Double { Appearance.GridGuide.bottomSheetImageDefaultHeight }

    func primaryAction(dismiss: @escaping (BottomActionSheetActionType) -> Void) -> BottomActionSheet<ContentView, ImageView>.Action {
        var action = primaryAction
        action.type = .primary
        action.inject(dismissAction: dismiss)
        return action
    }

    func secondaryAction(dismiss: @escaping (BottomActionSheetActionType) -> Void) -> BottomActionSheet<ContentView, ImageView>.Action? {
        var action = secondaryAction
        action?.type = .secondary
        action?.inject(dismissAction: dismiss)
        return action
    }
}
