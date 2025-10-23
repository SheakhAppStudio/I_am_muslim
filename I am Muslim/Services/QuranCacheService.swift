import Foundation

class QuranCacheService {
    static let shared = QuranCacheService()
    private let fileManager = FileManager.default
    
    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("QuranCache")
    }
    
    private init() {
        createCacheDirectoryIfNeeded()
    }
    
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Chapters
    func saveChapters(_ chapters: [QuranReadingChapter]) {
        let url = cacheDirectory.appendingPathComponent("chapters.json")
        save(chapters, to: url)
    }
    
    func loadChapters() -> [QuranReadingChapter]? {
        let url = cacheDirectory.appendingPathComponent("chapters.json")
        return load([QuranReadingChapter].self, from: url)
    }
    
    // MARK: - Translations
    func saveTranslations(_ translations: [QuranTranslation]) {
        let url = cacheDirectory.appendingPathComponent("translations.json")
        save(translations, to: url)
    }
    
    func loadTranslations() -> [QuranTranslation]? {
        let url = cacheDirectory.appendingPathComponent("translations.json")
        return load([QuranTranslation].self, from: url)
    }
    
    // MARK: - Verses
    func saveVerses(_ verses: [QuranReadingVerse], forChapter chapterId: Int) {
        let url = cacheDirectory.appendingPathComponent("verses_\(chapterId).json")
        save(verses, to: url)
    }
    
    func loadVerses(forChapter chapterId: Int) -> [QuranReadingVerse]? {
        let url = cacheDirectory.appendingPathComponent("verses_\(chapterId).json")
        return load([QuranReadingVerse].self, from: url)
    }
    
    // MARK: - Helper Methods
    private func save<T: Encodable>(_ data: T, to url: URL) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(data)
            try data.write(to: url)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    private func load<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            print("Error loading data: \(error)")
            return nil
        }
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        createCacheDirectoryIfNeeded()
    }
}
