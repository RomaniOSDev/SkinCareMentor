//
//  OnboardingView.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isCompleted: Bool
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Прогресс бар
                ProgressView(value: Double(viewModel.currentStep + 1), total: Double(viewModel.totalSteps))
                    .progressViewStyle(LinearProgressViewStyle(tint: .appButton))
                    .padding()
                
                ScrollView {
                    VStack(spacing: 30) {
                        if viewModel.currentStep == 0 {
                            welcomeScreen
                        } else if viewModel.currentStep <= viewModel.questions.count {
                            testQuestionView
                        } else if viewModel.currentStep == viewModel.questions.count + 1 {
                            concernsSelectionView
                        } else {
                            completionView
                        }
                    }
                    .padding()
                }
                
                // Кнопки навигации
                HStack {
                    if viewModel.currentStep > 0 {
                        Button("Back") {
                            viewModel.previousStep()
                        }
                        .foregroundColor(.appText.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Button(viewModel.currentStep == viewModel.totalSteps - 1 ? "Complete" : "Next") {
                        if viewModel.currentStep == viewModel.totalSteps - 1 {
                            viewModel.completeOnboarding()
                            isCompleted = true
                        } else {
                            // Определяем тип кожи перед переходом к экрану завершения
                            if viewModel.currentStep == viewModel.questions.count {
                                viewModel.userProfile.skinType = viewModel.determineSkinType()
                            }
                            viewModel.nextStep()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appButton)
                    .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
                    .disabled(viewModel.currentStep > 0 && 
                              viewModel.currentStep <= viewModel.questions.count && 
                              (viewModel.testAnswers.count < viewModel.currentStep))
                }
                .padding()
            }
        }
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.appButton)
            
            Text("Welcome to")
                .font(.title2)
                .foregroundColor(.appText)
            
            Text("Skin Care Mentor")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.appText)
            
            Text("Your personalized skin care assistant")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.appText.opacity(0.7))
                .padding(.horizontal)
        }
        .padding(.vertical, 60)
    }
    
    private var testQuestionView: some View {
        VStack(spacing: 30) {
            Text("Question \(viewModel.currentStep) of \(viewModel.questions.count)")
                .font(.caption)
                .foregroundColor(.appText.opacity(0.6))
            
            Text(viewModel.questions[viewModel.currentStep - 1])
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(spacing: 15) {
                ForEach(0..<5) { index in
                    Button(action: {
                        viewModel.answerQuestion(index)
                    }) {
                        HStack {
                            Text(answerText(for: index))
                                .foregroundColor(.appText)
                            Spacer()
                            if viewModel.currentStep > 0 &&
                               viewModel.currentStep <= viewModel.questions.count &&
                               viewModel.testAnswers.count > viewModel.currentStep - 1 &&
                               viewModel.testAnswers[viewModel.currentStep - 1] == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.appButton)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.currentStep > 0 &&
                                      viewModel.currentStep <= viewModel.questions.count &&
                                      viewModel.testAnswers.count > viewModel.currentStep - 1 &&
                                      viewModel.testAnswers[viewModel.currentStep - 1] == index ?
                                      Color.appButton.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                        .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                }
            }
        }
    }
    
    private var concernsSelectionView: some View {
        VStack(spacing: 30) {
            Text("Select Skin Concerns")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appText)
            
            Text("You can select multiple options")
                .font(.caption)
                .foregroundColor(.appText.opacity(0.6))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(SkinConcern.allCases, id: \.self) { concern in
                    Button(action: {
                        if viewModel.selectedConcerns.contains(concern) {
                            viewModel.selectedConcerns.remove(concern)
                        } else {
                            viewModel.selectedConcerns.insert(concern)
                        }
                    }) {
                        VStack {
                            Image(systemName: iconForConcern(concern))
                                .font(.system(size: 30))
                                .foregroundColor(viewModel.selectedConcerns.contains(concern) ? .appButton : .gray)
                            
                            Text(concern.rawValue)
                                .font(.caption)
                                .foregroundColor(.appText)
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.selectedConcerns.contains(concern) ?
                                      Color.appButton.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                        .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                }
            }
            
            TextField("Allergies (optional)", text: $viewModel.allergies)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Profile Created!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.appText)
            
            if let skinType = viewModel.userProfile.skinType {
                VStack(spacing: 10) {
                    Text("Your Skin Type:")
                        .font(.headline)
                        .foregroundColor(.appText)
                    Text(skinType.rawValue)
                        .font(.title2)
                        .foregroundColor(.appText)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appButton.opacity(0.2))
                )
            }
            
            Text("Your personalized routine has been created and is ready to use!")
                .multilineTextAlignment(.center)
                .foregroundColor(.appText.opacity(0.7))
        }
        .padding(.vertical, 60)
    }
    
    private func answerText(for index: Int) -> String {
        switch index {
        case 0: return "Very dry, tight"
        case 1: return "Dry"
        case 2: return "Normal"
        case 3: return "Oily, shiny"
        case 4: return "Irritated, red"
        default: return ""
        }
    }
    
    private func iconForConcern(_ concern: SkinConcern) -> String {
        switch concern {
        case .acne: return "circle.grid.cross"
        case .wrinkles: return "waveform.path"
        case .pigmentation: return "circle.hexagongrid"
        case .redness: return "heart.fill"
        case .dehydration: return "drop.fill"
        case .pores: return "circle.grid.2x2"
        }
    }
}

#Preview {
    OnboardingView(isCompleted: .constant(false))
}

