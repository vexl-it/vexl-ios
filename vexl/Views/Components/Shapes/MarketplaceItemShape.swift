//
//  MarketplaceItemShape.swift
//  vexl
//
//  Created by Diego Espinoza on 27/09/22.
//

import SwiftUI

struct MarketplaceItemShape: Shape {
    let horizontalStartPoint: CGFloat

    func path(in rect: CGRect) -> Path {
        let height = rect.height - 10
        return Path { path in
            path.addRoundedRect(in: .init(x: 0, y: 0, width: rect.width, height: height),
                                cornerSize: .init(width: Appearance.GridGuide.buttonCorner,
                                                  height: Appearance.GridGuide.buttonCorner))
            path.move(to: .init(x: horizontalStartPoint, y: height))
            path.addLine(to: .init(x: horizontalStartPoint + 10, y: rect.height))
            path.addLine(to: .init(x: horizontalStartPoint + 20, y: height))
        }
    }
}

#if DEBUG || DEVEL

struct MarketplaceItemShapeView: View {
    var body: some View {
        Text("Hello there")
            .frame(width: 200, height: 200)
            .background(Color.red)
            .clipShape(MarketplaceItemShape(horizontalStartPoint: 20))
            .frame(width: 250, height: 250)
    }
}

struct MarketplaceItemShapePreview: PreviewProvider {
    static var previews: some View {
        MarketplaceItemShapeView()
    }
}

#endif
