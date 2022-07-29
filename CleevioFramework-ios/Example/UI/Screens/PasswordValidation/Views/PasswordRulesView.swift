//
//  PasswordRulesView.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 11/11/20.
//

import SwiftUI

struct PasswordRulesView: View {

    var rules: [Rule]

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color(red: 207/255, green: 210/255, blue: 211/255, opacity: 0.2))
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text("Your password must have")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                ForEach(rules, id: \.id) { rule in
                    let foregroundColor = rule.isCompleted ?
                        Color(red: 0/255, green: 128/255, blue: 102/255, opacity: 0.6) :
                        Color(red: 60/255, green: 60/255, blue: 67/255, opacity: 0.6)

                    Label(rule.title, systemImage: rule.isCompleted ? "checkmark.circle.fill" : "minus")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundColor(foregroundColor)
                }
            }
            .padding(16)
        }
    }
}
