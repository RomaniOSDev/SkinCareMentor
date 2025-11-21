//
//  SkinCareRoutine.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation

struct SkinCareRoutine: Identifiable, Codable {
    let id: UUID
    var timeOfDay: TimeOfDay
    var steps: [RoutineStep]
    var isCompleted: Bool
    var scheduledDate: Date
    
    init(id: UUID = UUID(), timeOfDay: TimeOfDay, steps: [RoutineStep] = [], isCompleted: Bool = false, scheduledDate: Date = Date()) {
        self.id = id
        self.timeOfDay = timeOfDay
        self.steps = steps
        self.isCompleted = isCompleted
        self.scheduledDate = scheduledDate
    }
}

struct RoutineStep: Identifiable, Codable {
    let id: UUID
    var productType: ProductType
    var productName: String
    var instructions: String
    var isCompleted: Bool
    var order: Int
    var timerDuration: Int? // в секундах
    
    init(id: UUID = UUID(), productType: ProductType, productName: String, instructions: String, isCompleted: Bool = false, order: Int, timerDuration: Int? = nil) {
        self.id = id
        self.productType = productType
        self.productName = productName
        self.instructions = instructions
        self.isCompleted = isCompleted
        self.order = order
        self.timerDuration = timerDuration
    }
}

enum ProductType: String, CaseIterable, Codable {
    case cleanser = "Cleanser"
    case toner = "Toner"
    case serum = "Serum"
    case moisturizer = "Moisturizer"
    case sunscreen = "Sunscreen"
    case treatment = "Treatment"
    case mask = "Mask"
}

enum TimeOfDay: String, CaseIterable, Codable {
    case morning = "Morning"
    case evening = "Evening"
}

