//
//  CircleProgressAppearance.swift
//
//  Created by Thành Đỗ Long on 08.12.2021.
//

import SwiftUI

public class CircleProgressAppearance: ObservableObject {
    @Published public var padding: (edges: Edge.Set, length: CGFloat) = (edges: .all, length: 16)
    
    @Published public var backgroundCircleColor: Color = .black.opacity(0.1)
    @Published public var backgroundCircleStyle: StrokeStyle = .init(lineWidth: 15, lineCap: .round)
    
    @Published public var overlayCircleColor: Color = .blue
    @Published public var overlayCircleStyle: StrokeStyle = .init(lineWidth: 15, lineCap: .round)
    @Published public var overlayRotation: Angle = .zero
    
    @Published public var textColor: Color?
    @Published public var textFont: Font?
    @Published public var textWeight: Font.Weight?
    @Published public var textLineLimit: Int?
    
    @Published public var reverseProgress: Bool = false
    
    static public var `default`: CircleProgressAppearance {
        CircleProgressAppearance()
    }
}
