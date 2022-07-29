//
//  ComponentsList.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import SwiftUI
import Combine

struct ComponentsList: View {

    @ObservedObject private(set) var viewModel: ComponentsListViewModel

    var body: some View {
        NavigationView {
            List(viewModel.components, id: \.name) { component in
                NavigationLink(component.name,
                               destination: displayDestination(with: component))
            }
            .navigationBarTitle("CleevioUI")
            .animation(.easeOut(duration: 0.3))
        }
    }
}

// MARK: - Displaying Content

private extension ComponentsList {
    func displayDestination(with component: Component) -> some View {
        let view: AnyView

        switch component.id {
        case .mapScene:
            view = AnyView(PullUpContainerView())
        case .pinCode:
            view = AnyView(PinCodeOptionsView(viewModel: PinCodeOptionsViewModel()))
        case .passwordValidation:
            view = AnyView(PasswordValidationView(viewModel: PasswordValidationViewModel()))
        case .phoneNumberScene:
            view = AnyView(PhoneNumber(viewModel: .init(container: viewModel.container)))
        case .oneTimePassword:
            view = AnyView(OneTimePassword())
        }

        return view
    }
}

#if DEBUG
struct ComponentsList_Previews: PreviewProvider {
    static var previews: some View {
        ComponentsList(viewModel: .init(dependencies: .preview,
                                        components: Component.mockedData))
    }
}
#endif
