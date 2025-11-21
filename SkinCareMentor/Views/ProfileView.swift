//
//  ProfileView.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import SwiftUI
import StoreKit

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    ScrollView {
                        VStack(spacing: 25) {
                    // Информация о профиле
                    if let profile = viewModel.userProfile {
                        ProfileInfoCard(profile: profile)
                    }
                    
                    // Статистика
                    StatisticsCard(viewModel: viewModel)
                    
                    // Настройки
                    SettingsSection(viewModel: viewModel, showingOnboarding: $showingOnboarding)
                    
                    // О приложении
                    AboutSection()
                }
                .padding()
                }
            }
                }
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView(isCompleted: .constant(false))
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct ProfileInfoCard: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.appButton)
                
                VStack(alignment: .leading, spacing: 5) {
                    if let skinType = profile.skinType {
                        Text("Skin Type")
                            .font(.caption)
                            .foregroundColor(.appText.opacity(0.7))
                        Text(skinType.rawValue)
                            .font(.headline)
                            .foregroundColor(.appText)
                    } else {
                        Text("Skin type not determined")
                            .font(.subheadline)
                            .foregroundColor(.appText.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            
            if !profile.skinConcerns.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Skin Concerns:")
                        .font(.caption)
                        .foregroundColor(.appText.opacity(0.7))
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(profile.skinConcerns, id: \.self) { concern in
                            Text(concern.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.appButton.opacity(0.2))
                            )
                        }
                    }
                }
            }
            
            if !profile.allergies.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Allergies:")
                        .font(.caption)
                        .foregroundColor(.appText.opacity(0.7))
                    Text(profile.allergies.joined(separator: ", "))
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appButton.opacity(0.2))
        )
    }
}

struct StatisticsCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.appText)
            
            HStack(spacing: 20) {
                StatisticItem(
                    icon: "checkmark.circle.fill",
                    title: "Completed Routines",
                    value: "\(viewModel.completedRoutinesCount)",
                    color: .green
                )
                
                StatisticItem(
                    icon: "book.fill",
                    title: "Diary Entries",
                    value: "\(viewModel.totalDiaryEntries)",
                    color: .blue
                )
            }
            
            if viewModel.averageSkinCondition > 0 {
                HStack {
                    Text("Average Skin Condition:")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= Int(viewModel.averageSkinCondition) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(index <= Int(viewModel.averageSkinCondition) ? .yellow : .gray)
                        }
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct StatisticItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.appText.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct SettingsSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var showingOnboarding: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Настройки")
                .font(.headline)
                .foregroundColor(.appText)
            
                    Button(action: {
                        viewModel.resetOnboarding()
                        showingOnboarding = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.appButton)
                    Text("Return test")
                        .foregroundColor(.appText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appText.opacity(0.6))
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                // Сброс данных
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    Text("Reset all data")
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("About")
                .font(.headline)
                .foregroundColor(.appText)
            
            Button(action: {
                // Оценить приложение
                SKStoreReviewController.requestReview()
            }) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.appButton)
                    Text("Rate App")
                        .foregroundColor(.appText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appText.opacity(0.6))
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                // Privacy Policy
                if let url = URL(string: "https://www.termsfeed.com/live/020d00a3-4bd3-4e98-beb3-5d54e2d005f7") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.appButton)
                    Text("Privacy Policy")
                        .foregroundColor(.appText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appText.opacity(0.6))
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                // Terms of Service
                if let url = URL(string: "https://www.termsfeed.com/live/23659469-c4bc-450f-92e4-d80bd0d6b61a") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.appButton)
                    Text("Terms of Service")
                        .foregroundColor(.appText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appText.opacity(0.6))
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}


#Preview {
    ProfileView()
}

