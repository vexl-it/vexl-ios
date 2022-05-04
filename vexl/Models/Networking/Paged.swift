//
//  Paged.swift
//  vexl
//
//  Created by Diego Espinoza on 30/04/22.
//

import Foundation

struct Paged<T: Codable>: Codable {
    var nextLink: String?
    var prevLink: String?
    var currentPage: Int
    var currentPageSize: Int
    var pagesTotal: Int
    var itemsCount: Int
    var itemsCountTotal: Int
    var items: [T]
}
