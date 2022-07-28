//
//  CenteredLabelStyle.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 11/11/20.
//

import SwiftUI

struct CenteredLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
        }
    }
}
