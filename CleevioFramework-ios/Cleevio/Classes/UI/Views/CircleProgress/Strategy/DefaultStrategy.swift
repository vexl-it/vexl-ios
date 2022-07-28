//
//  DefaultStrategy.swift
//
//  Created by Thành Đỗ Long on 06.12.2021.
//

import Combine
import CoreGraphics

final public class DefaultStrategy: CircularProgressBarStategyType {
    public var progressStart: CGFloat { 0.0 }
    public var progressEnd: CGFloat { 1.0 }
    
    @Published public var progressTo: CGFloat
    public var progressToPublished: Published<CGFloat> { _progressTo }
    public var progressToPublisher: Published<CGFloat>.Publisher { $progressTo }
    
    @Published public  var title: String?
    public var titlePublished: Published<String?> { _title }
    public var titlePublisher: Published<String?>.Publisher { $title }
    
    public init(progressStart: CGFloat, title: String? = nil) {
        self.progressTo = progressStart
        self.title = title
    }
}


