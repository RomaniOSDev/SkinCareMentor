//
//  SkinDiaryView.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import SwiftUI

struct SkinDiaryView: View {
    @StateObject private var viewModel = DiaryViewModel()
    @State private var showingNewEntry = false
    @State private var selectedEntry: SkinDiaryEntry?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    Text("Skin Diary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                    // График состояния кожи
                    if viewModel.entries.count >= 2 {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Skin Condition Chart")
                                .font(.headline)
                                .foregroundColor(.appText)
                            
                            ChartView(data: viewModel.conditionTrend)
                                .frame(height: 200)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                    }
                    
                    // Календарь записей
                    CalendarView(viewModel: viewModel)
                    
                    // Список записей
                    if !viewModel.entries.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("All Entries")
                                .font(.headline)
                                .foregroundColor(.appText)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.entries.sorted { $0.date > $1.date }) { entry in
                                DiaryEntryRow(entry: entry) {
                                    selectedEntry = entry
                                }
                            }
                        }
                    } else {
                        EmptyDiaryView()
                    }
                }
                .padding()
                        }
                    }
                }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewEntry = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NewDiaryEntryView(viewModel: viewModel)
            }
            .sheet(item: $selectedEntry) { entry in
                DiaryEntryDetailView(entry: entry, viewModel: viewModel)
            }
        }
    }
}

struct CalendarView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @State private var currentMonth = Date()
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(currentMonth, format: .dateTime.month(.wide).year())
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Простой календарь
            let days = daysInMonth(currentMonth)
            let entries = viewModel.entriesForMonth(currentMonth)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        let entry = viewModel.entryForDate(date)
                        CalendarDayView(date: date, hasEntry: entry != nil, condition: entry?.skinCondition)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private func daysInMonth(_ date: Date) -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        return days
    }
}

struct CalendarDayView: View {
    let date: Date
    let hasEntry: Bool
    let condition: Int?
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption)
                .foregroundColor(Calendar.current.isDateInToday(date) ? .appButton : .appText)
            
            if hasEntry, let condition = condition {
                HStack(spacing: 1) {
                    ForEach(1...min(condition, 3), id: \.self) { _ in
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(hasEntry ? Color.appButton.opacity(0.2) : Color.clear)
                )
    }
}

struct ChartView: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 5
            let minValue = data.min() ?? 1
            let range = maxValue - minValue
            
            Path { path in
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) / CGFloat(max(data.count - 1, 1)) * geometry.size.width
                    let y = geometry.size.height - (CGFloat(value - minValue) / CGFloat(range > 0 ? range : 1) * geometry.size.height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.appButton, lineWidth: 2)
        }
    }
}

struct DiaryEntryRow: View {
    let entry: SkinDiaryEntry
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.date, style: .date)
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    if !entry.notes.isEmpty {
                        Text(entry.notes)
                            .font(.caption)
                            .foregroundColor(.appText.opacity(0.7))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= entry.skinCondition ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(index <= entry.skinCondition ? .yellow : .gray)
                    }
                }
                
                if entry.photoData != nil {
                    Image(systemName: "photo")
                        .foregroundColor(.blue)
                }
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

struct EmptyDiaryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book")
                .font(.system(size: 60))
                .foregroundColor(.appText.opacity(0.6))
            
            Text("No Entries Yet")
                .font(.headline)
                .foregroundColor(.appText)
            
            Text("Start tracking your skin condition")
                .font(.caption)
                .foregroundColor(.appText.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct NewDiaryEntryView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var condition: Int = 3
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок с кнопками
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundColor(.appText)
                        }
                        
                        Spacer()
                        
                        Text("New Entry")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.newEntry.skinCondition = condition
                            viewModel.newEntry.notes = notes
                            viewModel.saveEntry()
                            dismiss()
                        }) {
                            Text("Save")
                                .foregroundColor(.appButton)
                                .fontWeight(.semibold)
                                .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            // Дата
                            VStack {
                                HStack {
                                    Text("Date")
                                        .foregroundStyle(.colorText)
                                    Spacer()
                                }
                                DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                                    .foregroundColor(.appText)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundStyle(.colorButton)
                                    }
                            }
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.colorButton)
                                    .opacity(0.3)
                            }
                            
                            // Состояние кожи
                            VStack {
                                HStack {
                                    Text("Skin Condition")
                                        .foregroundStyle(.colorText)
                                    Spacer()
                                }
                                HStack {
                                    Text("Rating")
                                        .foregroundColor(.appText)
                                    Spacer()
                                    HStack(spacing: 5) {
                                        ForEach(1...5, id: \.self) { index in
                                            Button(action: {
                                                condition = index
                                            }) {
                                                Image(systemName: index <= condition ? "star.fill" : "star")
                                                    .foregroundColor(index <= condition ? .yellow : .gray)
                                                    .font(.title3)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(.colorButton)
                                }
                            }
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.colorButton)
                                    .opacity(0.3)
                            }
                            
                            // Заметки
                            VStack {
                                HStack {
                                    Text("Notes")
                                        .foregroundStyle(.colorText)
                                    Spacer()
                                }
                                TextEditor(text: $notes)
                                    .foregroundColor(.appText)
                                    .frame(height: 150)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundStyle(.colorButton)
                                    }
                            }
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.colorButton)
                                    .opacity(0.3)
                            }
                            
                            // Фото
                            VStack {
                                HStack {
                                    Text("Photo")
                                        .foregroundStyle(.colorText)
                                    Spacer()
                                }
                                Button(action: {
                                    viewModel.showingImagePicker = true
                                }) {
                                    HStack {
                                        if let image = viewModel.selectedImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .cornerRadius(8)
                                        } else {
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.appText)
                                            Text("Add Photo")
                                                .foregroundColor(.appText)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundStyle(.colorButton)
                                    }
                                }
                            }
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.colorButton)
                                    .opacity(0.3)
                            }
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
        }
    }
}

struct DiaryEntryDetailView: View {
    let entry: SkinDiaryEntry
    @ObservedObject var viewModel: DiaryViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Заголовок
                Text("Entry")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(entry.date, style: .date)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                    
                    HStack {
                        Text("Condition:")
                            .foregroundColor(.appText)
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= entry.skinCondition ? "star.fill" : "star")
                                    .foregroundColor(index <= entry.skinCondition ? .yellow : .gray)
                            }
                        }
                    }
                    
                    if !entry.notes.isEmpty {
                    Text("Notes:")
                        .font(.headline)
                        .foregroundColor(.appText)
                    Text(entry.notes)
                        .foregroundColor(.appText)
                    }
                    
                    if let photoData = entry.photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    }
                    }
                    .padding()
                }
            }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Delete") {
                        viewModel.deleteEntry(entry)
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    SkinDiaryView()
}

