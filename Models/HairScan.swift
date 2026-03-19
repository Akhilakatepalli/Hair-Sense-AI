//
//  HairScan.swift
//  Hair AI
//

import Foundation

struct HairScan: Codable, Identifiable {
    let id: String
    let userId: String
    let imageURL: String
    let createdAt: Date
    let analysis: HairAnalysis

    enum CodingKeys: String, CodingKey {
        case id
        case userId    = "user_id"
        case imageURL  = "image_url"
        case createdAt = "created_at"
        case analysis
    }
}

struct HairIssue: Codable, Identifiable {
    let id: String
    let title: String
    let icon: String
    let colorHex: String
    let description: String
    let tips: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case icon
        case colorHex = "color_hex"
        case description
        case tips
    }
}

struct Remedy: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let description: String
    let steps: [String]
}
