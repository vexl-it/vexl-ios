//
//  RegisterPhoneView.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import Foundation
import SwiftUI

struct RegisterPhoneView: View {

    @ObservedObject var viewModel: RegisterPhoneViewModel

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("What’s your phone number?")
                    .textStyle(.h2)
                
                Text("Your number will be anonymous")
            }
            .frame(maxWidth: .infinity)
            .modifier(CardViewModifier())
            .padding(.all, Appearance.GridGuide.padding)

            Spacer()

            Text("Register Phone 2")
                .foregroundColor(Color.white)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
