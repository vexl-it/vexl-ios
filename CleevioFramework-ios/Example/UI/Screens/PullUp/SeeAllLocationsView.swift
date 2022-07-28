//
//  SeeAllLocationsView.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 2/17/21.
//

import SwiftUI

struct SeeAllLocationsView: View {
    @Binding var showingAll: Bool

    init(showingAll: Binding<Bool>) {
        self._showingAll = showingAll
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(1 ... 15, id: \.self) { _ in
                        LocationRow()
                    }
                }
            }
            .navigationBarTitle("Recently Viewed")
            .navigationBarItems(
                trailing:
                    Button("Close") {
                        showingAll = false
                    }
            )
        }
        .onDisappear {
            
        }
    }
}
