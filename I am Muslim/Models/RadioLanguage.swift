import Foundation

enum RadioLanguage: String, CaseIterable, Identifiable {
    case arabic = "ar"
    case english = "eng"
    case french = "fr"
    case russian = "ru"
    case german = "de"
    case spanish = "es"
    case turkish = "tr"
    case chinese = "cn"
    case thai = "th"
    case urdu = "ur"
    case bengali = "bn"
    case bosnian = "bs"
    case uyghur = "ug"
    case persian = "fa"
    case tajik = "tg"
    case malayalam = "ml"
    case tagalog = "tl"
    case indonesian = "id"
    case portuguese = "pt"
    case hausa = "ha"
    case swahili = "sw"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .arabic: return "العربية"
        case .english: return "English"
        case .french: return "Français"
        case .russian: return "Русский"
        case .german: return "Deutsch"
        case .spanish: return "Español"
        case .turkish: return "Türkçe"
        case .chinese: return "中文"
        case .thai: return "ไทย"
        case .urdu: return "اردو"
        case .bengali: return "বাংলা"
        case .bosnian: return "Bosanski"
        case .uyghur: return "ئۇيغۇرچە"
        case .persian: return "فارسی"
        case .tajik: return "Тоҷикӣ"
        case .malayalam: return "മലയാളം"
        case .tagalog: return "Tagalog"
        case .indonesian: return "Bahasa Indonesia"
        case .portuguese: return "Português"
        case .hausa: return "Hausa"
        case .swahili: return "Kiswahili"
        }
    }
}
