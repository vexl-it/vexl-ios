//
//  CounterManager.swift
//  CleevioRoutersExample
//
//  Created by Thành Đỗ Long on 14.01.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

protocol CounterManagerType: AnyObject {
    var counter: Int { get set }
}

final class CounterManager: CounterManagerType {
    var counter: Int
    
    init(counter: Int = 0) {
        self.counter = counter
    }
}
