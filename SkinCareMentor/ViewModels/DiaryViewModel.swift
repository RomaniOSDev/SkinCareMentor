//
//  DiaryViewModel.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation
import Combine
import SwiftUI

class DiaryViewModel: ObservableObject {
    @Published var entries: [SkinDiaryEntry] = []
    @Published var selectedDate: Date = Date()
    @Published var newEntry = SkinDiaryEntry()
    @Published var showingImagePicker = false
    @Published var selectedImage: UIImage?
    
    private let storageService = StorageService.shared
    
    init() {
        loadEntries()
    }
    
    func loadEntries() {
        entries = storageService.loadDiaryEntries()
    }
    
    func saveEntry() {
        if let image = selectedImage {
            newEntry.photoData = image.jpegData(compressionQuality: 0.8)
        }
        newEntry.date = selectedDate
        
        if let index = entries.firstIndex(where: { $0.id == newEntry.id }) {
            entries[index] = newEntry
        } else {
            entries.append(newEntry)
        }
        
        storageService.saveDiaryEntries(entries)
        newEntry = SkinDiaryEntry()
        selectedImage = nil
    }
    
    func deleteEntry(_ entry: SkinDiaryEntry) {
        entries.removeAll { $0.id == entry.id }
        storageService.saveDiaryEntries(entries)
    }
    
    func entryForDate(_ date: Date) -> SkinDiaryEntry? {
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func entriesForMonth(_ date: Date) -> [SkinDiaryEntry] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return entries.filter { entry in
            let entryMonth = calendar.component(.month, from: entry.date)
            let entryYear = calendar.component(.year, from: entry.date)
            return entryMonth == month && entryYear == year
        }
    }
    
    var averageSkinCondition: Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + $1.skinCondition }
        return Double(sum) / Double(entries.count)
    }
    
    var conditionTrend: [Double] {
        let sortedEntries = entries.sorted { $0.date < $1.date }
        return sortedEntries.map { Double($0.skinCondition) }
    }
}

