//
//  KnowledgeViewModel.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation
import Combine

class KnowledgeViewModel: ObservableObject {
    @Published var articles: [KnowledgeArticle] = []
    @Published var filteredArticles: [KnowledgeArticle] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: ArticleCategory?
    @Published var bookmarkedArticleIds: Set<UUID> = []
    @Published var readArticleIds: Set<UUID> = []
    
    private let storageService = StorageService.shared
    private let dataService = DataService.shared
    
    init() {
        loadArticles()
        loadBookmarks()
        loadReadHistory()
    }
    
    func loadArticles() {
        let defaultArticles = dataService.getDefaultArticles()
        let customArticles = storageService.loadCustomArticles()
        articles = defaultArticles + customArticles
        filteredArticles = articles
    }
    
    func loadBookmarks() {
        let ids = storageService.loadBookmarkedArticles()
        bookmarkedArticleIds = Set(ids)
    }
    
    func loadReadHistory() {
        let ids = storageService.loadReadArticles()
        readArticleIds = Set(ids)
    }
    
    func filterArticles() {
        var filtered = articles
        
        // Фильтр по категории
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Фильтр по поиску
        if !searchText.isEmpty {
            filtered = filtered.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredArticles = filtered
    }
    
    func toggleBookmark(_ articleId: UUID) {
        if bookmarkedArticleIds.contains(articleId) {
            bookmarkedArticleIds.remove(articleId)
        } else {
            bookmarkedArticleIds.insert(articleId)
        }
        
        storageService.saveBookmarkedArticles(Array(bookmarkedArticleIds))
    }
    
    func markAsRead(_ articleId: UUID) {
        readArticleIds.insert(articleId)
        storageService.saveReadArticles(Array(readArticleIds))
    }
    
    func getRecommendedArticles(for skinType: SkinType?) -> [KnowledgeArticle] {
        guard let skinType = skinType else { return [] }
        
        // Простая логика рекомендаций
        return articles.filter { article in
            switch skinType {
            case .dry:
                return article.title.localizedCaseInsensitiveContains("moistur") || article.title.localizedCaseInsensitiveContains("dry") || article.category == .basics
            case .oily:
                return article.title.localizedCaseInsensitiveContains("acne") || article.title.localizedCaseInsensitiveContains("pore") || article.category == .problems
            case .sensitive:
                return article.title.localizedCaseInsensitiveContains("sensitive") || article.category == .basics
            default:
                return true
            }
        }
    }
    
    var bookmarkedArticles: [KnowledgeArticle] {
        return articles.filter { bookmarkedArticleIds.contains($0.id) }
    }
    
    func addCustomArticle(_ article: KnowledgeArticle) {
        var customArticles = storageService.loadCustomArticles()
        customArticles.append(article)
        storageService.saveCustomArticles(customArticles)
        loadArticles()
    }
    
    func deleteCustomArticle(_ article: KnowledgeArticle) {
        var customArticles = storageService.loadCustomArticles()
        customArticles.removeAll { $0.id == article.id }
        storageService.saveCustomArticles(customArticles)
        loadArticles()
    }
    
    func isCustomArticle(_ article: KnowledgeArticle) -> Bool {
        let defaultArticleIds = Set(dataService.getDefaultArticles().map { $0.id })
        return !defaultArticleIds.contains(article.id)
    }
}

