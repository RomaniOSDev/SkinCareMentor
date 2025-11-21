//
//  StorageService.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation
import Combine

class StorageService: ObservableObject {
    static let shared = StorageService()
    
    private let userDefaults = UserDefaults.standard
    private let userProfileKey = "userProfile"
    private let routinesKey = "routines"
    private let diaryEntriesKey = "diaryEntries"
    private let bookmarkedArticlesKey = "bookmarkedArticles"
    private let readArticlesKey = "readArticles"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private let customArticlesKey = "customArticles"
    
    private init() {}
    
    // MARK: - User Profile
    func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            userDefaults.set(encoded, forKey: userProfileKey)
        }
    }
    
    func loadUserProfile() -> UserProfile? {
        if let data = userDefaults.data(forKey: userProfileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return nil
    }
    
    // MARK: - Routines
    func saveRoutines(_ routines: [SkinCareRoutine]) {
        if let encoded = try? JSONEncoder().encode(routines) {
            userDefaults.set(encoded, forKey: routinesKey)
        }
    }
    
    func loadRoutines() -> [SkinCareRoutine] {
        if let data = userDefaults.data(forKey: routinesKey),
           let routines = try? JSONDecoder().decode([SkinCareRoutine].self, from: data) {
            return routines
        }
        return []
    }
    
    // MARK: - Diary Entries
    func saveDiaryEntries(_ entries: [SkinDiaryEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: diaryEntriesKey)
        }
    }
    
    func loadDiaryEntries() -> [SkinDiaryEntry] {
        if let data = userDefaults.data(forKey: diaryEntriesKey),
           let entries = try? JSONDecoder().decode([SkinDiaryEntry].self, from: data) {
            return entries
        }
        return []
    }
    
    // MARK: - Bookmarks
    func saveBookmarkedArticles(_ articleIds: [UUID]) {
        let ids = articleIds.map { $0.uuidString }
        userDefaults.set(ids, forKey: bookmarkedArticlesKey)
    }
    
    func loadBookmarkedArticles() -> [UUID] {
        if let ids = userDefaults.stringArray(forKey: bookmarkedArticlesKey) {
            return ids.compactMap { UUID(uuidString: $0) }
        }
        return []
    }
    
    // MARK: - Read Articles
    func saveReadArticles(_ articleIds: [UUID]) {
        let ids = articleIds.map { $0.uuidString }
        userDefaults.set(ids, forKey: readArticlesKey)
    }
    
    func loadReadArticles() -> [UUID] {
        if let ids = userDefaults.stringArray(forKey: readArticlesKey) {
            return ids.compactMap { UUID(uuidString: $0) }
        }
        return []
    }
    
    // MARK: - Custom Articles
    func saveCustomArticles(_ articles: [KnowledgeArticle]) {
        if let encoded = try? JSONEncoder().encode(articles) {
            userDefaults.set(encoded, forKey: customArticlesKey)
        }
    }
    
    func loadCustomArticles() -> [KnowledgeArticle] {
        if let data = userDefaults.data(forKey: customArticlesKey),
           let articles = try? JSONDecoder().decode([KnowledgeArticle].self, from: data) {
            return articles
        }
        return []
    }
    
    // MARK: - Onboarding
    func setOnboardingCompleted(_ completed: Bool) {
        userDefaults.set(completed, forKey: hasCompletedOnboardingKey)
    }
    
    func hasCompletedOnboarding() -> Bool {
        return userDefaults.bool(forKey: hasCompletedOnboardingKey)
    }
}

