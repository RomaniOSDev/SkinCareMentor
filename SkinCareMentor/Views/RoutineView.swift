//
//  RoutineView.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import SwiftUI

struct RoutineView: View {
    @StateObject private var viewModel: RoutineViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(routine: SkinCareRoutine) {
        _viewModel = StateObject(wrappedValue: RoutineViewModel(routine: routine))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок экрана
                    Text("Routine")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Заголовок
                            VStack(spacing: 10) {
                                Image(systemName: viewModel.routine.timeOfDay == .morning ? "sunrise.fill" : "moon.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.appButton)
                                
                        Text("\(viewModel.routine.timeOfDay.rawValue) Routine")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .appButton))
                            .frame(height: 8)
                        
                        Text("\(Int(viewModel.progress * 100))% completed")
                            .font(.caption)
                            .foregroundColor(.appText.opacity(0.7))
                    }
                    .padding()
                    
                    // Список шагов
                    VStack(spacing: 15) {
                        ForEach(viewModel.routine.steps.sorted(by: { $0.order < $1.order })) { step in
                            RoutineStepView(
                                step: step,
                                viewModel: viewModel
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопка завершения
                    if viewModel.progress == 1.0 {
                        Button(action: {
                            viewModel.completeRoutine()
                            dismiss()
                        }) {
                    Text("Complete Routine")
                        .font(.headline)
                        .foregroundColor(.appText)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                )
                                .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
                        }
                        .padding()
                    }
                }
                        .padding(.vertical)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    
}

struct RoutineStepView: View {
    let step: RoutineStep
    @ObservedObject var viewModel: RoutineViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Номер шага
                Text("\(step.order)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(step.isCompleted ? Color.green : Color.appButton)
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(step.productType.rawValue)
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    Text(step.productName)
                        .font(.subheadline)
                        .foregroundColor(.appText.opacity(0.7))
                }
                
                Spacer()
                
                // Чекбокс
                Button(action: {
                    viewModel.toggleStepCompletion(step.id)
                }) {
                    Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(step.isCompleted ? .green : .gray)
                }
            }
            
            // Инструкции
            Text(step.instructions)
                .font(.caption)
                .foregroundColor(.appText.opacity(0.7))
                .padding(.leading, 40)
            
            // Таймер для масок
            if let duration = step.timerDuration, step.productType == .mask {
                TimerView(
                    stepId: step.id,
                    duration: duration,
                    viewModel: viewModel
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(step.isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        )
    }
}

struct TimerView: View {
    let stepId: UUID
    let duration: Int
    @ObservedObject var viewModel: RoutineViewModel
    
    var body: some View {
        HStack {
            if viewModel.activeTimerStepId == stepId && viewModel.isTimerRunning {
                    Text(viewModel.formattedTimer)
                        .font(.title2)
                        .monospacedDigit()
                        .foregroundColor(.appButton)
                
                Spacer()
                
                Button("Stop") {
                    viewModel.stopTimer()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
            } else {
                Button(action: {
                    viewModel.startTimer(for: stepId)
                }) {
                    HStack {
                        Image(systemName: "timer")
                        Text("Start Timer (\(duration / 60) min)")
                    }
                    .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.appButton)
                .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.leading, 40)
        .padding(.top, 5)
    }
}

#Preview {
    RoutineView(routine: SkinCareRoutine(
        timeOfDay: .morning,
        steps: [
            RoutineStep(productType: .cleanser, productName: "Очищающее средство", instructions: "Умойтесь", order: 1),
            RoutineStep(productType: .mask, productName: "Маска", instructions: "Нанесите на 10 минут", order: 2, timerDuration: 600)
        ]
    ))
}

