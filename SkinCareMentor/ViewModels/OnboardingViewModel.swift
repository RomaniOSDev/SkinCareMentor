//
//  OnboardingViewModel.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var userProfile = UserProfile()
    @Published var selectedConcerns: Set<SkinConcern> = []
    @Published var allergies: String = ""
    
    // Тест на тип кожи
    @Published var testAnswers: [Int] = []
    private let testQuestions = [
        "How does your skin look 2-3 hours after washing without applying cream?",
        "How do your pores look?",
        "How often do you get inflammation and pimples?",
        "How does your skin react to the sun?",
        "How does your skin look in the middle of the day?",
        "How does your skin feel after washing?",
        "How often do you feel tightness?"
    ]
    
    private let storageService = StorageService.shared
    private let dataService = DataService.shared
    
    var questions: [String] {
        return testQuestions
    }
    
    var totalSteps: Int {
        return testQuestions.count + 2 // вопросы + выбор проблем + завершение
    }
    
    func answerQuestion(_ answer: Int) {
        // currentStep начинается с 1 для первого вопроса, поэтому используем currentStep - 1 для индексации
        let questionIndex = currentStep - 1
        if currentStep > 0 && currentStep <= testQuestions.count {
            if testAnswers.count <= questionIndex {
                testAnswers.append(answer)
            } else {
                testAnswers[questionIndex] = answer
            }
        }
    }
    
    func determineSkinType() -> SkinType {
        // Простая логика определения типа кожи на основе ответов
        let dryAnswers = testAnswers.filter { $0 == 0 || $0 == 1 }.count
        let oilyAnswers = testAnswers.filter { $0 == 2 || $0 == 3 }.count
        
        if dryAnswers > oilyAnswers + 1 {
            return .dry
        } else if oilyAnswers > dryAnswers + 1 {
            return .oily
        } else if testAnswers.contains(where: { $0 == 4 }) {
            return .sensitive
        } else if dryAnswers == oilyAnswers {
            return .combination
        } else {
            return .normal
        }
    }
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func completeOnboarding() {
        // Определяем тип кожи (если еще не определен)
        if userProfile.skinType == nil && testAnswers.count == testQuestions.count {
            userProfile.skinType = determineSkinType()
        }
        
        // Сохраняем проблемы кожи
        userProfile.skinConcerns = Array(selectedConcerns)
        
        // Сохраняем аллергии
        if !allergies.isEmpty {
            userProfile.allergies = allergies.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        // Сохраняем профиль
        storageService.saveUserProfile(userProfile)
        
        // Генерируем рутины
        generateRoutines()
        
        // Отмечаем онбординг как завершенный
        storageService.setOnboardingCompleted(true)
    }
    
    private func generateRoutines() {
        guard let skinType = userProfile.skinType else { return }
        
        let morningRoutine = dataService.generateRoutine(
            for: skinType,
            timeOfDay: .morning,
            concerns: userProfile.skinConcerns
        )
        
        let eveningRoutine = dataService.generateRoutine(
            for: skinType,
            timeOfDay: .evening,
            concerns: userProfile.skinConcerns
        )
        
        var routines = storageService.loadRoutines()
        routines.append(morningRoutine)
        routines.append(eveningRoutine)
        storageService.saveRoutines(routines)
    }
}

