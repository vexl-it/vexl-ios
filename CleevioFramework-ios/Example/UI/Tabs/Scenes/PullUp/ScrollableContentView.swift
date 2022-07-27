//
//  ScrollableContentView.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 2/15/21.
//

import SwiftUI

struct ScrollableContentView: View {
    @State private var showingAll = false

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 20) {
                Company(logoColor: .yellow)
                Company(logoColor: .green)
                Company(logoColor: .red)
                Company(logoColor: .olive)
                Company(logoColor: .green)
                Company(logoColor: .yellow)
                Company(logoColor: .red)
                Company(logoColor: .olive)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 150)

        SectionWithButton(showingAll: $showingAll)
            .fullScreenCover(isPresented: $showingAll, content: {
                SeeAllLocationsView(showingAll: $showingAll)
            })

        ForEach(1...10, id: \.self) { _ in
            LocationRow()
        }

        Spacer()
    }
}

struct Company: View {
    enum LogoColor: String {
        case yellow = "cleevioLogoYellow"
        case green  = "cleevioLogoGreen"
        case red = "cleevioLogoRed"
        case olive = "cleevioLogoOlive"
    }

    var logoColor: LogoColor

    var body: some View {
        VStack(spacing: 5) {
            Image(logoColor.rawValue)
            Text("Cleevio")
                .fontWeight(.semibold)
            Text("10 min")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct SectionWithButton: View {
    @Binding var showingAll: Bool

    var body: some View {
        HStack {
            Text("Recently Viewed")
                .font(.headline)
                .foregroundColor(.gray)

            Spacer()

            Button("See All") {
                showingAll = true
            }
            .font(Font.system(size: 15, weight: .semibold, design: .default))
            .foregroundColor(.black)
        }
        .padding(.horizontal, 20)

        Divider()
            .padding(.leading, 20)
    }
}

struct LocationRow: View {
    var body: some View {
        HStack(spacing: 10) {
            Image("icLocation")
            VStack(alignment: .leading) {
                Text("Cupertino, California")
                    .font(.title2)
                Text("One Apple Park Way, Cuipertino, CA 95014")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)

        Divider()
            .padding(.leading, 20)
    }
}
