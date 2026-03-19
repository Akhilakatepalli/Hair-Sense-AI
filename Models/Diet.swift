//
//  DietModel.swift
//  Hair AI
//

import Foundation

struct DietRecommendation: Codable, Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
    let description: String
    let benefits: [String]
}

struct DietPlan: Codable, Identifiable {
    let id: String
    let userId: String
    let recommendations: [DietRecommendation]
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId          = "user_id"
        case recommendations
        case createdAt       = "created_at"
    }
}
