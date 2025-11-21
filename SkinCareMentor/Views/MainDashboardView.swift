//
//  MainDashboardView.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardHomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            SkinDiaryView()
                .tabItem {
                    Label("Diary", systemImage: "book.fill")
                }
                .tag(1)
            
            KnowledgeBaseView()
                .tabItem {
                    Label("Knowledge", systemImage: "bookmark.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.appButton)
    }
}

struct DashboardHomeView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var showingRoutine = false
    @State private var showingNewDiaryEntry = false
    @State private var showingKnowledgeBase = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    Text("Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    ScrollView {
                    VStack(spacing: 20) {
                        // Приветствие
                        if let profile = viewModel.userProfile {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Hello!")
                                        .font(.title2)
                                        .foregroundColor(.appText)
                                    if let skinType = profile.skinType {
                                        Text("Skin Type: \(skinType.rawValue)")
                                            .font(.subheadline)
                                            .foregroundColor(.appText.opacity(0.7))
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    
                    // Текущая рутина
                    if let routine = viewModel.currentRoutine {
                        RoutineCard(routine: routine) {
                            showingRoutine = true
                        }
                    } else {
                        NoRoutineCard()
                    }
                    
                    // Прогресс
                    if let routine = viewModel.currentRoutine {
                        ProgressCard(progress: viewModel.routineProgress)
                    }
                    
                    // Последние записи дневника
                    if !viewModel.recentDiaryEntries.isEmpty {
                        RecentDiaryCard(entries: viewModel.recentDiaryEntries)
                    }
                    
                    // Быстрые действия
                    QuickActionsView(
                        onNewEntry: { showingNewDiaryEntry = true },
                        onKnowledgeBase: { showingKnowledgeBase = true }
                    )
                }
                .padding()
                    }
                    }
                }
            }
            .refreshable {
                viewModel.refresh()
            }
            .sheet(isPresented: $showingRoutine) {
                if let routine = viewModel.currentRoutine {
                    RoutineView(routine: routine)
                }
            }
            .sheet(isPresented: $showingNewDiaryEntry) {
                SkinDiaryView()
            }
            .sheet(isPresented: $showingKnowledgeBase) {
                KnowledgeBaseView()
            }
        }
    
}

struct RoutineCard: View {
    let routine: SkinCareRoutine
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: routine.timeOfDay == .morning ? "sunrise.fill" : "moon.fill")
                        .font(.title)
                        .foregroundColor(.appButton)
                    
                    VStack(alignment: .leading) {
                        Text("\(routine.timeOfDay.rawValue) Routine")
                            .font(.headline)
                            .foregroundColor(.appText)
                        Text("\(routine.steps.count) steps")
                            .font(.caption)
                            .foregroundColor(.appText.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appText.opacity(0.6))
                }
                
                let completedSteps = routine.steps.filter { $0.isCompleted }.count
                ProgressView(value: Double(completedSteps), total: Double(routine.steps.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .appButton))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appButton.opacity(0.2))
            )
            .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct NoRoutineCard: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Today's Routine Completed!")
                .font(.headline)
                .foregroundColor(.appText)
            
            Text("Great job! A new routine will be available tomorrow.")
                .font(.caption)
                .foregroundColor(.appText.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
    }
}

struct ProgressCard: View {
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Progress")
                .font(.headline)
                .foregroundColor(.appText)
            
            HStack {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .appButton))
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.appText.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct RecentDiaryCard: View {
    let entries: [SkinDiaryEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Entries")
                .font(.headline)
                .foregroundColor(.appText)
            
            ForEach(entries.prefix(3)) { entry in
                HStack {
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= entry.skinCondition ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(index <= entry.skinCondition ? .yellow : .gray)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct QuickActionsView: View {
    let onNewEntry: () -> Void
    let onKnowledgeBase: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.appText)
            
            HStack(spacing: 15) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "New Entry",
                    color: .appButton,
                    action: onNewEntry
                )
                
                QuickActionButton(
                    icon: "book.fill",
                    title: "Knowledge Base",
                    color: .appText,
                    action: onKnowledgeBase
                )
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.appText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            )
            .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainDashboardView()
}

