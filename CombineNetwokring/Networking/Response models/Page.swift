//
//  Page.swift
//  CombineNetwokring
//
//  Created by Marin Tutuc on 05.02.2023.
//

import Foundation

// MARK: - Page
struct Page: Codable {
    let page, perPage, total, totalPages: Int?
    let data: [Datum]?
    let support: Support?
    
    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case data, support
    }
}
