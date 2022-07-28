//
//  SectionView.swift
//  CleevioDemo
//
//  Created by Diego on 25/12/21.
//

import SwiftUI

struct SectionView: View {
    let section: Section
    
    var body: some View {
        NavigationView {
            List {
                ForEach(section.content, id: \.name) { content in
                    NavigationLink(destination: content.view) {
                        Text(content.name)
                    }
                }
            }
            .navigationTitle(section.name)
        }
        .tabItem {
            Image(systemName: section.icon)
            Text(section.name)
        }
    }
}
