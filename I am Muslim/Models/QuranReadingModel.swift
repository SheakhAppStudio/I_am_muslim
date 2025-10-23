import Foundation
import SwiftUI

// MARK: - API Response Wrappers
struct ChaptersResponse: Codable {
    let chapters: [QuranReadingChapter]
}

struct VersesResponse: Codable {
    let verses: [QuranReadingVerse]
    let pagination: Pagination?
}

struct Pagination: Codable {
    let currentPage: Int
    let nextPage: Int?
    let totalPages: Int
    let totalRecords: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case nextPage = "next_page"
        case totalPages = "total_pages"
        case totalRecords = "total_records"
    }
}

struct TranslationsResponse: Codable {
    let translations: [QuranTranslation]
}

struct QuranTranslation: Identifiable, Codable {
    let id: Int
    let name: String
    let authorName: String
    let slug: String?
    let languageName: String
    let translatedName: TranslatedName?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case authorName = "author_name"
        case slug
        case languageName = "language_name"
        case translatedName = "translated_name"
    }
}

struct TranslationMeta: Codable {
    let translationName: String
    let authorName: String
    let filters: TranslationFilters
    
    enum CodingKeys: String, CodingKey {
        case translationName = "translation_name"
        case authorName = "author_name"
        case filters
    }
}

struct TranslationFilters: Codable {
    let verseKey: String
    let resourceId: Int
    
    enum CodingKeys: String, CodingKey {
        case verseKey = "verse_key"
        case resourceId = "resource_id"
    }
}

// MARK: - Chapter Models
struct QuranReadingChapter: Identifiable, Codable {
    let id: Int
    let revelationPlace: String
    let revelationOrder: Int
    let bismillahPre: Bool
    let nameSimple: String
    let nameComplex: String
    let nameArabic: String
    let versesCount: Int
    let pages: [Int]
    let translatedName: TranslatedName
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case revelationPlace = "revelation_place"
        case revelationOrder = "revelation_order"
        case bismillahPre = "bismillah_pre"
        case nameSimple = "name_simple"
        case nameComplex = "name_complex"
        case nameArabic = "name_arabic"
        case versesCount = "verses_count"
        case pages = "pages"
        case translatedName = "translated_name"
    }
}

struct TranslatedName: Codable {
    let languageName: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case languageName = "language_name"
        case name = "name"
    }
}

// MARK: - Verse Models
struct QuranReadingVerse: Identifiable, Codable {
    let id: Int
    let verseNumber: Int
    let verseKey: String
    let textUthmani: String?
    let textIndopak: String?
    let juzNumber: Int
    let hizbNumber: Int
    let rubElHizbNumber: Int
    let rukuNumber: Int
    let manzilNumber: Int
    let sajdahNumber: Int?
    let pageNumber: Int
    let translations: [VerseTranslation]?
    
    var cleanTranslationText: String {
        translations?.first?.text.replacingOccurrences(of: "۝", with: "") ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case verseNumber = "verse_number"
        case verseKey = "verse_key"
        case textUthmani = "text_uthmani"
        case textIndopak = "text_indopak"
        case juzNumber = "juz_number"
        case hizbNumber = "hizb_number"
        case rubElHizbNumber = "rub_el_hizb_number"
        case rukuNumber = "ruku_number"
        case manzilNumber = "manzil_number"
        case sajdahNumber = "sajdah_number"
        case pageNumber = "page_number"
        case translations = "translations"
    }
}

struct VerseTranslation: Codable {
    let resourceId: Int
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case resourceId = "resource_id"
        case text = "text"
    }
}



// MARK: - Style Models
enum ArabicFont: String, CaseIterable {
    case uthmani = "KFGQPC Uthmanic Script HAFS Regular"
    case me_quran = "me_quran"
    case noor_e_huda = "noorehuda"
    
    var displayName: String {
        switch self {
        case .uthmani: return "Uthmani HAFS"
        case .me_quran: return "Me Quran"
        case .noor_e_huda: return "Noor E Huda"
        }
    }
}

struct QuranCardStyle {
    let name: String
    let background: Color
    let textColor: Color
    let translationColor: Color
    
    static let styles: [QuranCardStyle] = [
        QuranCardStyle(name: "Classic", background: .white, textColor: .black, translationColor: .gray),
        QuranCardStyle(name: "Dark", background: Color.black.opacity(0.8), textColor: .white, translationColor: .gray),
        QuranCardStyle(name: "Sepia", background: Color(red: 0.98, green: 0.92, blue: 0.84), textColor: .brown, translationColor: .gray),
        QuranCardStyle(name: "Night", background: Color(red: 0.1, green: 0.1, blue: 0.2), textColor: .white, translationColor: Color.white.opacity(0.7))
    ]
}

// MARK: - API Response Models
struct QuranResponse<T: Codable>: Codable {
    let data: T
}
