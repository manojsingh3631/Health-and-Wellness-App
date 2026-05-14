// FAQ.swift
// BluePond Wellness

import Foundation

struct FAQ: Codable {
    var id: String
    var question: String
    var answer: String
    var category: String
    var displayOrder: Int
    var isPublished: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case question
        case answer
        case category
        case displayOrder = "display_order"
        case isPublished  = "is_published"
    }
}
