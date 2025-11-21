//
//  ProfileViewModel.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var routines: [SkinCareRoutine] = []
    @Published var diaryEntries: [SkinDiaryEntry] = []
    @Published var showOnboarding = false
    
    private let storageService = StorageService.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        userProfile = storageService.loadUserProfile()
        routines = storageService.loadRoutines()
        diaryEntries = storageService.loadDiaryEntries()
    }
    
    func resetOnboarding() {
        storageService.setOnboardingCompleted(false)
        showOnboarding = true
    }
    
    var completedRoutinesCount: Int {
        return routines.filter { $0.isCompleted }.count
    }
    
    var totalDiaryEntries: Int {
        return diaryEntries.count
    }
    
    var averageSkinCondition: Double {
        guard !diaryEntries.isEmpty else { return 0 }
        let sum = diaryEntries.reduce(0) { $0 + $1.skinCondition }
        return Double(sum) / Double(diaryEntries.count)
    }
}

