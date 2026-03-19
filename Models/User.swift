//
//  User.swift
//  Hair AI
//
//  Created by Akhila Katepalli on 3/13/26.
//

//
//  User.swift
//  Hair AI
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var age: Int
    var profileImageURL: String?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case age
        case profileImageURL = "profile_image_url"
        case createdAt       = "created_at"
    }
}
