//
//  UserProfile.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    let id: UUID
    var skinType: SkinType?
    var skinConcerns: [SkinConcern]
    var allergies: [String]
    var createdAt: Date
    
    init(id: UUID = UUID(), skinType: SkinType? = nil, skinConcerns: [SkinConcern] = [], allergies: [String] = [], createdAt: Date = Date()) {
        self.id = id
        self.skinType = skinType
        self.skinConcerns = skinConcerns
        self.allergies = allergies
        self.createdAt = createdAt
    }
}

enum SkinType: String, CaseIterable, Codable {
    case dry = "Dry"
    case oily = "Oily"
    case combination = "Combination"
    case normal = "Normal"
    case sensitive = "Sensitive"
}

enum SkinConcern: String, CaseIterable, Codable {
    case acne = "Acne"
    case wrinkles = "Wrinkles"
    case pigmentation = "Pigmentation"
    case redness = "Redness"
    case dehydration = "Dehydration"
    case pores = "Enlarged Pores"
}

