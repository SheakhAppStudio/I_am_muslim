import SwiftUI

struct TranslationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var quranService = QuranReadingService.shared
    @State private var searchText = ""
    
    private var filteredTranslations: [QuranTranslation] {
        if searchText.isEmpty {
            return quranService.availableTranslations
        }
        return quranService.availableTranslations.filter { translation in
            translation.name.lowercased().contains(searchText.lowercased()) ||
            translation.authorName.lowercased().contains(searchText.lowercased()) ||
            translation.languageName.lowercased().contains(searchText.lowercased())
        }
    }
    
    private var groupedTranslations: [String: [QuranTranslation]] {
        Dictionary(grouping: filteredTranslations) { $0.languageName }
            .sorted { $0.key < $1.key }
            .reduce(into: [:]) { result, element in
                result[element.key] = element.value.sorted { $0.name < $1.name }
            }
    }
    
    @MainActor
    private func loadTranslationsIfNeeded() async {
        if quranService.availableTranslations.isEmpty {
            do {
                _ = try await quranService.fetchTranslations()
            } catch {
                print("Error loading translations: \(error)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with Islamic Pattern
                IslamicTheme.primaryGradient
                    .ignoresSafeArea()
                    .overlay(
                        IslamicPatternView(color: .white, opacity: 0.05)
                            .ignoresSafeArea()
                    )
                
                VStack(spacing: 0) {
                    // Search bar
                    TranslationSearchBar(text: $searchText, placeholder: "Search translations")
                        .padding()
                    
                    ScrollView {
                        LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                            // No Translation Option
                            VStack(spacing: 16) {
                                Button(action: {
                                    quranService.selectedTranslationId = nil
                                    if let chapter = quranService.currentChapter {
                                        Task {
                                            await quranService.reloadCurrentChapterWithNewTranslation()
                                        }
                                    }
                                    dismiss()
                                }) {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Arabic Only")
                                                .font(.system(.headline, design: .serif))
                                                .foregroundColor(.white)
                                            
                                            Text("No translation")
                                                .font(.system(.subheadline, design: .serif))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        Spacer()
                                        
                                        if quranService.selectedTranslationId == nil {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(IslamicTheme.accentColor)
                                                .imageScale(.large)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(quranService.selectedTranslationId == nil ? 0.15 : 0.05))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                            ForEach(Array(groupedTranslations.keys.sorted()), id: \.self) { language in
                                Section(header: LanguageHeader(language: language)) {
                                    ForEach(groupedTranslations[language] ?? []) { translation in
                                        TranslationRow(translation: translation, isSelected: quranService.selectedTranslationId == translation.id)
                                            .onTapGesture {
                                                quranService.selectedTranslationId = translation.id
                                                if let chapter = quranService.currentChapter {
                                                    Task {
                                                        await quranService.reloadCurrentChapterWithNewTranslation()
                                                    }
                                                }
                                                dismiss()
                                            }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Translation")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadTranslationsIfNeeded()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(IslamicTheme.accentColor)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}


struct TranslationRow: View {
    let translation: QuranTranslation
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(translation.name)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.white)
                
                Text(translation.authorName)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(IslamicTheme.accentColor)
                    .imageScale(.large)
            }
        }
        .padding()
        .background(Color.white.opacity(isSelected ? 0.15 : 0.05))
        .cornerRadius(12)
        .contentShape(Rectangle())
    }
}

struct LanguageHeader: View {
    let language: String
    
    var body: some View {
        HStack {
            Text(language)
                .font(.system(.title3, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(IslamicTheme.accentColor)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            Color.black.opacity(0.3)
                .cornerRadius(12)
        )
        .padding(.top, 8)
    }
}

struct TranslationSearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(10)
    }
}
