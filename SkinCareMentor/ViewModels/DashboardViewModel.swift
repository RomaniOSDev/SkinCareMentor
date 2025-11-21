//
//  DashboardViewModel.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var currentRoutine: SkinCareRoutine?
    @Published var routines: [SkinCareRoutine] = []
    @Published var recentDiaryEntries: [SkinDiaryEntry] = []
    
    private let storageService = StorageService.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        userProfile = storageService.loadUserProfile()
        routines = storageService.loadRoutines()
        
        // Определяем текущую рутину (утренняя до 14:00, вечерняя после)
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: TimeOfDay = hour < 14 ? .morning : .evening
        
        currentRoutine = routines.first { routine in
            routine.timeOfDay == timeOfDay &&
            Calendar.current.isDateInToday(routine.scheduledDate) &&
            !routine.isCompleted
        }
        
        // Загружаем последние записи дневника
        let allEntries = storageService.loadDiaryEntries()
        recentDiaryEntries = Array(allEntries.sorted { $0.date > $1.date }.prefix(3))
    }
    
    func refresh() {
        loadData()
    }
    
    var routineProgress: Double {
        guard let routine = currentRoutine else { return 0 }
        let completedSteps = routine.steps.filter { $0.isCompleted }.count
        return Double(completedSteps) / Double(routine.steps.count)
    }
    
    var hasActiveRoutine: Bool {
        return currentRoutine != nil
    }
}

