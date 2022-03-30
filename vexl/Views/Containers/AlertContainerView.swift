//
//  AlertContainerView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/03/22.
//

import SwiftUI
import Cleevio

struct AlertContainerView<Content: View>: View {
    @Binding var error: AlertError?
    var content: () -> Content

    var body: some View {
        content()
        .alert(item: $error) { alert in
            Alert(title: Text(alert.message), message: nil, dismissButton: Alert.Button.default(Text(L.generalOk())))
        }
    }
}
