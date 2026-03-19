//
//  HairAnalysis.swift
//  Hair AI
//

import Foundation

struct HairAnalysis: Codable {
    let score: Int
    let label: String
    let summary: String
    let issues: [HairIssue]
    let dietRecommendations: [DietRecommendation]
    let remedies: [Remedy]

    enum CodingKeys: String, CodingKey {
        case score
        case label
        case summary
        case issues
        case dietRecommendations = "diet_recommendations"
        case remedies
    }
}
