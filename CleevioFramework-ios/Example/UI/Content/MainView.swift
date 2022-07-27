//
//  MainView.swift
//  CleevioDemo
//
//  Created by Diego on 25/12/21.
//

import SwiftUI

protocol Content {
    var name: String { get }
    var view: AnyView { get }
}

protocol Section {
    var name: String { get }
    var icon: String { get }
    
    var content: [Content] { get }
}

struct MainView: View {
    
    var sections: [Section] {
        [Element(),
         Component(),
         Scene()]
    }
    
    var body: some View {
        TabView {
            ForEach(sections, id: \.name) { section in
                SectionView(section: section)
            }
        }
    }
}
