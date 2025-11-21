//
//  KnowledgeArticle.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation

struct KnowledgeArticle: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var category: ArticleCategory
    var difficulty: DifficultyLevel
    
    init(id: UUID = UUID(), title: String, content: String, category: ArticleCategory, difficulty: DifficultyLevel) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.difficulty = difficulty
    }
}

enum ArticleCategory: String, CaseIterable, Codable {
    case basics = "Basics"
    case ingredients = "Ingredients"
    case routines = "Routines"
    case problems = "Problems"
    case myths = "Myths"
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case expert = "Expert"
}

