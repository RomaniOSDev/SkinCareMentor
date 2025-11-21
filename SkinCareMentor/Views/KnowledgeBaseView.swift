//
//  KnowledgeBaseView.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import SwiftUI

struct KnowledgeBaseView: View {
    @StateObject private var viewModel = KnowledgeViewModel()
    @State private var selectedArticle: KnowledgeArticle?
    @State private var showingNewArticle = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    Text("Knowledge Base")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    // Поиск
                    SearchBar(text: $viewModel.searchText)
                        .onChange(of: viewModel.searchText) { _ in
                            viewModel.filterArticles()
                        }
                    
                    // Фильтры категорий
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                        CategoryFilterButton(
                            title: "All",
                            isSelected: viewModel.selectedCategory == nil
                        ) {
                            viewModel.selectedCategory = nil
                            viewModel.filterArticles()
                        }
                        
                        ForEach(ArticleCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                title: category.rawValue,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                                viewModel.filterArticles()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Список статей
                if viewModel.filteredArticles.isEmpty {
                    EmptyArticlesView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.filteredArticles) { article in
                                ArticleRow(article: article, viewModel: viewModel) {
                                    selectedArticle = article
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewArticle = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article, viewModel: viewModel)
            }
            .sheet(isPresented: $showingNewArticle) {
                NewArticleView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadBookmarks()
            viewModel.loadReadHistory()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appText.opacity(0.6))
            
            TextField("Search articles...", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appText.opacity(0.6))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.appButton : Color.gray.opacity(0.2))
            )
            .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
        }
    }
}

struct ArticleRow: View {
    let article: KnowledgeArticle
    @ObservedObject var viewModel: KnowledgeViewModel
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            viewModel.markAsRead(article.id)
            action()
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(article.title)
                            .font(.headline)
                            .foregroundColor(.appText)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 10) {
                            Label(article.category.rawValue, systemImage: "folder.fill")
                                .font(.caption)
                                .foregroundColor(.appText.opacity(0.7))
                            
                            Label(article.difficulty.rawValue, systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(.appText.opacity(0.7))
                            
                            if viewModel.isCustomArticle(article) {
                                Text("My")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.blue.opacity(0.2))
                                    )
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button(action: {
                            viewModel.toggleBookmark(article.id)
                        }) {
                            Image(systemName: viewModel.bookmarkedArticleIds.contains(article.id) ? "bookmark.fill" : "bookmark")
                                .foregroundColor(viewModel.bookmarkedArticleIds.contains(article.id) ? .appButton : .gray)
                        }
                        
                        if viewModel.readArticleIds.contains(article.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                }
                
                Text(article.content.prefix(100) + "...")
                    .font(.caption)
                    .foregroundColor(.appText.opacity(0.7))
                    .lineLimit(2)
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
}

struct ArticleDetailView: View {
    let article: KnowledgeArticle
    @ObservedObject var viewModel: KnowledgeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Заголовок
                Text("Article")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(article.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                    
                    HStack(spacing: 15) {
                        Label(article.category.rawValue, systemImage: "folder.fill")
                            .font(.subheadline)
                            .foregroundColor(.appText.opacity(0.7))
                        
                        Label(article.difficulty.rawValue, systemImage: "star.fill")
                            .font(.subheadline)
                            .foregroundColor(.appText.opacity(0.7))
                        
                        if viewModel.isCustomArticle(article) {
                            Text("My Article")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.2))
                                )
                        }
                    }
                    
                    Divider()
                    
                    Text(article.content)
                        .font(.body)
                        .lineSpacing(5)
                        .foregroundColor(.appText)
                }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            viewModel.toggleBookmark(article.id)
                        }) {
                            Image(systemName: viewModel.bookmarkedArticleIds.contains(article.id) ? "bookmark.fill" : "bookmark")
                                .foregroundColor(viewModel.bookmarkedArticleIds.contains(article.id) ? .appButton : .gray)
                        }
                        
                        if viewModel.isCustomArticle(article) {
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .alert("Delete Article?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteCustomArticle(article)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this article?")
            }
        }
    }
}

struct EmptyArticlesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.appText.opacity(0.6))
            
            Text("No Articles Found")
                .font(.headline)
                .foregroundColor(.appText)
            
            Text("Try changing search filters")
                .font(.caption)
                            .foregroundColor(.appText.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NewArticleView: View {
    @ObservedObject var viewModel: KnowledgeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCategory: ArticleCategory = .basics
    @State private var selectedDifficulty: DifficultyLevel = .beginner
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack{
                    // Заголовок с кнопками
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundColor(.appText)
                        }
                        
                        Spacer()
                        
                        Text("New Article")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Spacer()
                        
                        Button(action: {
                            saveArticle()
                        }) {
                            Text("Save")
                                .foregroundColor(title.isEmpty || content.isEmpty ? .appText.opacity(0.5) : .appButton)
                                .fontWeight(.semibold)
                                .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 2)
                        }
                        .disabled(title.isEmpty || content.isEmpty)
                    }
                    .padding()
                    
                    VStack {
                        VStack{
                            HStack {
                                Text("Title")
                                    .foregroundStyle(.colorText)
                                Spacer()
                            }
                            TextField("Enter article title", text: $title)
                                .foregroundColor(.appText)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(.colorButton)
                                }
                        }.padding(10)
                        .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.colorButton)
                                    .opacity(0.3)
                            }
                        
                        
                        VStack{
                        HStack {
                            Text("Category")
                                .foregroundStyle(.colorText)
                            Spacer()
                        }
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(ArticleCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue)
                                        .foregroundColor(.appText)
                                        .tag(category)
                                }
                            }
                            .foregroundColor(.appText)
                        }.padding(10)
                        .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.colorButton)
                                    .opacity(0.3)
                            }
                        
                        VStack{
                        HStack {
                            Text("Difficulty Level")
                                .foregroundStyle(.colorText)
                            Spacer()
                        }
                            Picker("Level", selection: $selectedDifficulty) {
                                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue)
                                        .foregroundColor(.appText)
                                        .tag(level)
                                }
                            }
                            .foregroundColor(.appText)
                        }.padding(10)
                        .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.colorButton)
                                    .opacity(0.3)
                            }
                        
                        VStack{
                        HStack {
                            Text("Content")
                                .foregroundStyle(.colorText)
                            Spacer()
                        }
                            TextEditor(text: $content)
                                .foregroundColor(.appText)
                                .frame(height: 200)
                        }.padding(10)
                        .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.colorButton)
                                    .opacity(0.3)
                            }
                        
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.appBackground)
                }
                .padding()
            }
        }
    }
    
    private func saveArticle() {
        let newArticle = KnowledgeArticle(
            title: title,
            content: content,
            category: selectedCategory,
            difficulty: selectedDifficulty
        )
        viewModel.addCustomArticle(newArticle)
        dismiss()
    }
}

#Preview {
    KnowledgeBaseView()
}

