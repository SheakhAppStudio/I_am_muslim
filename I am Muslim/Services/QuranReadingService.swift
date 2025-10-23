import Foundation
import SwiftUI

class QuranReadingService: ObservableObject {
    static let shared = QuranReadingService()
    private let baseURL = "https://api.quran.com/api/v4"
    
    @Published var chapters: [QuranReadingChapter] = []
    @Published var currentChapter: QuranReadingChapter?
    @Published var currentVerses: [QuranReadingVerse] = []
    @Published var availableTranslations: [QuranTranslation] = []
    
    // Settings
    @AppStorage("selectedTranslationId") var selectedTranslationIdRaw: Int = -1
    
    var selectedTranslationId: Int? {
        get { selectedTranslationIdRaw == -1 ? nil : selectedTranslationIdRaw }
        set { selectedTranslationIdRaw = newValue ?? -1 }
    }
    @AppStorage("arabicTextSize") var arabicTextSize: Double = 28
    @AppStorage("translationTextSize") var translationTextSize: Double = 16
    @AppStorage("selectedArabicFont") var selectedArabicFont: String = ArabicFont.uthmani.rawValue
    @AppStorage("selectedCardStyleIndex") var selectedCardStyleIndex: Int = 0
    
    var selectedCardStyle: QuranCardStyle {
        QuranCardStyle.styles[selectedCardStyleIndex]
    }
    
    var currentArabicFont: ArabicFont {
        ArabicFont(rawValue: selectedArabicFont) ?? .uthmani
    }
    
    private init() {}
    
    @MainActor
    func fetchChapters() async throws -> [QuranReadingChapter] {
        // Try to load from cache first
        if let cachedChapters = QuranCacheService.shared.loadChapters() {
            chapters = cachedChapters
            return chapters
        }
        
        // If not in cache, fetch from API
        let url = URL(string: "\(baseURL)/chapters?language=en")!
        do {
            let (data, urlResponse) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
                print("Chapters API Status Code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(ChaptersResponse.self, from: data)
            chapters = response.chapters
            
            // Save to cache
            QuranCacheService.shared.saveChapters(chapters)
            
            return chapters
        } catch {
            print("Chapters API Error: \(error)")
            throw error
        }
    }
    
    @MainActor
    func fetchVerses(forChapter chapterId: Int) async throws -> [QuranReadingVerse] {
        // Try to load from cache first
        if let cachedVerses = QuranCacheService.shared.loadVerses(forChapter: chapterId) {
            // If we have a translation selected and the cached verses have translations, use cache
            if selectedTranslationId == nil || (cachedVerses.first?.translations?.isEmpty == false) {
                return cachedVerses
            }
        }
        
        // If not in cache or need translation, fetch from API
        var urlComponents = URLComponents(string: "\(baseURL)/verses/by_chapter/\(chapterId)")!
        
        var queryItems = [
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "words", value: "true"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "300"),
            URLQueryItem(name: "fields", value: "text_uthmani,text_indopak,translations")
        ]
        
        if let translationId = selectedTranslationId {
            queryItems.append(URLQueryItem(name: "translations", value: String(translationId)))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            print("Invalid URL for verses")
            throw URLError(.badURL)
        }
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
                print("Verses API Status Code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(VersesResponse.self, from: data)
            currentVerses = response.verses
            return currentVerses
        } catch {
            print("Verses API Error: \(error)")
            throw error
        }
    }
    
    @MainActor
    func fetchTranslations() async throws -> [QuranTranslation] {
        // Try to load from cache first
        if let cachedTranslations = QuranCacheService.shared.loadTranslations() {
            availableTranslations = cachedTranslations
            return availableTranslations
        }
        
        // If not in cache, fetch from API
        let url = URL(string: "\(baseURL)/resources/translations")!
        do {
            let (data, urlResponse) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
                print("Translations API Status Code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(TranslationsResponse.self, from: data)
            availableTranslations = response.translations
            
            // Save to cache
            QuranCacheService.shared.saveTranslations(availableTranslations)
            
            return availableTranslations
        } catch {
            print("Translations API Error: \(error)")
            throw error
        }
    }
    
    func setTranslation(_ translation: QuranTranslation?) {
        selectedTranslationId = translation?.id
        // Refresh verses if we have a current chapter
        if let chapter = currentChapter {
            Task {
                do {
                    currentVerses = try await fetchVerses(forChapter: chapter.id)
                } catch {
                    print("Failed to refresh verses with new translation: \(error)")
                }
            }
        }
    }
    
    func updateArabicFont(_ font: ArabicFont) {
        selectedArabicFont = font.rawValue
    }
    
    func updateCardStyle(_ index: Int) {
        selectedCardStyleIndex = index
    }
    
    func updateArabicTextSize(_ size: CGFloat) {
        arabicTextSize = size
    }
    
    func updateTranslationTextSize(_ size: Double) {
        translationTextSize = size
    }
    
    @MainActor
    func reloadCurrentChapterWithNewTranslation() async {
        guard let chapter = currentChapter else { return }
        do {
            currentVerses = try await fetchVerses(forChapter: chapter.id)
        } catch {
            print("Failed to reload verses with new translation: \(error)")
        }
    }
}
