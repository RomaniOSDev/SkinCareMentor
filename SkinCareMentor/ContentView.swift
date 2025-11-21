//
//  ContentView.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var hasCompletedOnboarding = StorageService.shared.hasCompletedOnboarding()
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            Group {
                if hasCompletedOnboarding {
                    MainDashboardView()
                } else {
                    OnboardingView(isCompleted: $hasCompletedOnboarding)
                }
            }
        }
        .onChange(of: hasCompletedOnboarding) { newValue in
            StorageService.shared.setOnboardingCompleted(newValue)
        }
    }
}

#Preview {
    ContentView()
}
