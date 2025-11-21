//
//  RoutineViewModel.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation
import Combine

class RoutineViewModel: ObservableObject {
    @Published var routine: SkinCareRoutine
    @Published var activeTimerStepId: UUID?
    @Published var timerRemaining: Int = 0
    @Published var isTimerRunning = false
    
    private var timer: Timer?
    private let storageService = StorageService.shared
    
    init(routine: SkinCareRoutine) {
        self.routine = routine
    }
    
    func toggleStepCompletion(_ stepId: UUID) {
        if let index = routine.steps.firstIndex(where: { $0.id == stepId }) {
            routine.steps[index].isCompleted.toggle()
            saveRoutine()
        }
    }
    
    func startTimer(for stepId: UUID) {
        guard let step = routine.steps.first(where: { $0.id == stepId }),
              let duration = step.timerDuration else { return }
        
        activeTimerStepId = stepId
        timerRemaining = duration
        isTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timerRemaining > 0 {
                self.timerRemaining -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        activeTimerStepId = nil
        timerRemaining = 0
    }
    
    func completeRoutine() {
        routine.isCompleted = true
        for index in routine.steps.indices {
            routine.steps[index].isCompleted = true
        }
        saveRoutine()
    }
    
    private func saveRoutine() {
        var routines = storageService.loadRoutines()
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index] = routine
        } else {
            routines.append(routine)
        }
        storageService.saveRoutines(routines)
    }
    
    var progress: Double {
        let completedSteps = routine.steps.filter { $0.isCompleted }.count
        return Double(completedSteps) / Double(routine.steps.count)
    }
    
    var formattedTimer: String {
        let minutes = timerRemaining / 60
        let seconds = timerRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    deinit {
        stopTimer()
    }
}

