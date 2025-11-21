//
//  SkinDiaryEntry.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation

struct SkinDiaryEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var skinCondition: Int // 1-5
    var notes: String
    var photoData: Data?
    var completedRoutines: [UUID]
    
    init(id: UUID = UUID(), date: Date = Date(), skinCondition: Int = 3, notes: String = "", photoData: Data? = nil, completedRoutines: [UUID] = []) {
        self.id = id
        self.date = date
        self.skinCondition = skinCondition
        self.notes = notes
        self.photoData = photoData
        self.completedRoutines = completedRoutines
    }
}

