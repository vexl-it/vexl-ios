//
//  CircularProgressBarStategyType.swift
//
//  Created by Thành Đỗ Long on 06.12.2021.
//

import SwiftUI

public protocol CircularProgressBarStategyType: ObservableObject {
    associatedtype TextType: Equatable
    
    var progressStart: CGFloat { get }
    var progressTo: CGFloat { get }
    var progressToPublished: Published<CGFloat> { get }
    var progressToPublisher: Published<CGFloat>.Publisher { get }
    var progressEnd: CGFloat { get }

    var title: TextType { get }
    var titlePublished: Published<TextType> { get }
    var titlePublisher: Published<TextType>.Publisher { get }
    
    var localizedTitle: String { get }
}

extension CircularProgressBarStategyType {
    public var localizedTitle: String { title as? String ?? "" }
}
