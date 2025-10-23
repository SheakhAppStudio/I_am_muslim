import SwiftUI

struct ReadQuranView: View {
    @ObservedObject private var quranService = QuranReadingService.shared
    @State private var selectedChapter: QuranReadingChapter?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var searchText = ""
    @State private var showTranslationPicker = false
    @State private var showTextSettings = false
    @State private var showBackgroundPicker = false
    
    @MainActor
    private func loadInitialData() async {
        isLoading = true
        do {
            // Load chapters and translations in parallel
            async let chaptersTask = quranService.fetchChapters()
            async let translationsTask = quranService.fetchTranslations()
            let (chapters, translations) = try await (chaptersTask, translationsTask)
            print("Loaded \(chapters.count) chapters and \(translations.count) translations")
        } catch {
            print("Error loading initial data: \(error)")
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private var filteredChapters: [QuranReadingChapter] {
        if searchText.isEmpty {
            return quranService.chapters
        }
        return quranService.chapters.filter { chapter in
            chapter.nameSimple.lowercased().contains(searchText.lowercased()) ||
            chapter.translatedName.name.lowercased().contains(searchText.lowercased()) ||
            String(chapter.id).contains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            // Background with Islamic Pattern
            IslamicTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    IslamicPatternView(color: .white, opacity: 0.05)
                        .ignoresSafeArea()
                )
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    if let chapter = selectedChapter {
                        Button(action: {
                            selectedChapter = nil
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                Text(chapter.nameSimple)
                                    .font(.system(.title2, design: .serif))
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                    }
                }
                .padding()
                
                if selectedChapter == nil {
                    // Search bar and Settings Row
                    VStack(spacing: 12) {
                        SearchBar(text: $searchText)
                            .padding(.horizontal)
                        
                        // Quran Settings Toolbar
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                // Translation Button
                                Button(action: { showTranslationPicker = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "text.book.closed")
                                        Text("Translation")
                                            .font(.system(.subheadline, design: .serif))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                // Text Settings Button
                                Button(action: { showTextSettings = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "textformat.size")
                                        Text("Text Size")
                                            .font(.system(.subheadline, design: .serif))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                // Background Button
                                Button(action: { showBackgroundPicker = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "photo")
                                        Text("Background")
                                            .font(.system(.subheadline, design: .serif))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 8)
                    }
                }
                
                ScrollView {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 40)
                    } else if selectedChapter != nil {
                        VersesView(verses: quranService.currentVerses)
                            .environmentObject(quranService)
                            .padding()
                    } else {
                        ChaptersList(chapters: filteredChapters) { chapter in
                            Task {
                                await loadChapter(chapter)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .fullScreenCover(isPresented: $showTextSettings) {
            TextSettingsView()
                .environmentObject(quranService)
        }
        .fullScreenCover(isPresented: $showBackgroundPicker) {
            BackgroundPickerView()
                .environmentObject(quranService)
        }
        .fullScreenCover(isPresented: $showTranslationPicker) {
            TranslationPickerView()
        }
        .task {
            await loadInitialData()
        }
    }
    

    
    @MainActor
    private func loadChapter(_ chapter: QuranReadingChapter) async {
        isLoading = true
        do {
            selectedChapter = chapter
            quranService.currentChapter = chapter
            let verses = try await quranService.fetchVerses(forChapter: chapter.id)
            quranService.currentVerses = verses
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            selectedChapter = nil
        }
        isLoading = false
    }
}

// MARK: - Supporting Views
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search surah...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(10)
    }
}

struct ChaptersList: View {
    let chapters: [QuranReadingChapter]
    let onSelect: (QuranReadingChapter) -> Void
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(chapters) { chapter in
                ChapterRow(chapter: chapter)
                    .onTapGesture {
                        onSelect(chapter)
                    }
            }
        }
    }
}

struct ChapterRow: View {
    let chapter: QuranReadingChapter
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text("\(chapter.id)")
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.nameSimple)
                    .font(.system(.title3, design: .serif))
                    .foregroundColor(.white)
                
                Text("\(chapter.versesCount) verses • \(chapter.revelationPlace)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text(chapter.nameArabic)
                .font(.system(size: 24, weight: .medium, design: .serif))
                .foregroundColor(IslamicTheme.accentColor)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct VersesView: View {
    @EnvironmentObject private var quranService: QuranReadingService
    let verses: [QuranReadingVerse]
    
    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(verses) { verse in
                VStack(alignment: .trailing, spacing: 16) {
                    Text(verse.textUthmani ?? "")
                        .font(.custom(quranService.currentArabicFont.rawValue, size: quranService.arabicTextSize))
                        .foregroundColor(quranService.selectedCardStyle.textColor)
                        .multilineTextAlignment(.trailing)
                        .padding(.bottom, 8)
                    
                    if let translations = verse.translations, !translations.isEmpty {
                        Text(translations[0].text)
                            .font(.system(size: quranService.translationTextSize, design: .serif))
                            .foregroundColor(quranService.selectedCardStyle.translationColor)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text(verse.verseKey)
                        .font(.caption)
                        .foregroundColor(IslamicTheme.accentColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(
                    quranService.selectedCardStyle.background
                        .cornerRadius(12)
                )
            }
        }
    }
}
