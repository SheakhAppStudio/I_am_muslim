import Foundation

struct PrayerSettings: Codable, Equatable {
    enum CalculationMethod: String, CaseIterable, Codable {
        case mwl = "Muslim World League"
        case isna = "ISNA"
        case egyptian = "Egyptian"
        case karachi = "Karachi"
        case makkah = "Makkah"
        case tehran = "Tehran"
        case shia = "Shia Ithna Ashari"
        case gulf = "Gulf Region"
        
        var name: String {
            switch self {
            case .mwl: return "Muslim World League"
            case .isna: return "ISNA (North America)"
            case .egyptian: return "Egyptian"
            case .karachi: return "University of Islamic Sciences, Karachi"
            case .makkah: return "Umm al-Qura, Makkah"
            case .tehran: return "Institute of Geophysics, University of Tehran"
            case .shia: return "Shia Ithna Ashari"
            case .gulf: return "Gulf Region"
            }
        }
        
        var description: String {
            switch self {
            case .mwl: return "Muslim World League"
            case .isna: return "ISNA (North America)"
            case .egyptian: return "Egyptian General Authority"
            case .karachi: return "University of Islamic Sciences, Karachi"
            case .makkah: return "Umm Al-Qura University, Makkah"
            case .tehran: return "Institute of Geophysics, University of Tehran"
            case .shia: return "Shia Ithna-Ashari"
            case .gulf: return "Gulf Region"
            }
        }
    }
    
    enum AsrCalculation: String, CaseIterable, Codable {
        case standard = "Standard"
        case hanafi = "Hanafi"
        
        var name: String {
            switch self {
            case .standard: return "Standard (Shafi, Maliki, Hanbali)"
            case .hanafi: return "Hanafi"
            }
        }
        
        var description: String {
            switch self {
            case .standard: return "Standard (Shafi'i, Maliki, Hanbali)"
            case .hanafi: return "Hanafi"
            }
        }
    }
    
    var calculationMethod: CalculationMethod
    var asrCalculation: AsrCalculation
    var imsakAdjustment: Int
    var fajrAdjustment: Int
    var sunriseAdjustment: Int
    var dhuhrAdjustment: Int
    var asrAdjustment: Int
    var maghribAdjustment: Int
    var ishaAdjustment: Int
    
    static let `default` = PrayerSettings(
        calculationMethod: .isna,
        asrCalculation: .standard,
        imsakAdjustment: 0,
        fajrAdjustment: 0,
        sunriseAdjustment: 0,
        dhuhrAdjustment: 0,
        asrAdjustment: 0,
        maghribAdjustment: 0,
        ishaAdjustment: 0
    )
}

class PrayerSettingsManager: ObservableObject {
    static let shared = PrayerSettingsManager()
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "prayer_settings"
    var onSettingsChanged: (() -> Void)?
    
    @Published var settings: PrayerSettings {
        didSet {
            print("Prayer settings changed:")
            print("- Calculation Method: \(settings.calculationMethod.name)")
            print("- Asr Method: \(settings.asrCalculation.name)")
            saveSettings()
            onSettingsChanged?()
            print("Posting prayerSettingsChanged notification")
            NotificationCenter.default.post(name: .prayerSettingsChanged, object: nil)
        }
    }
    
    private init() {
        if let data = userDefaults.data(forKey: settingsKey),
           let savedSettings = try? JSONDecoder().decode(PrayerSettings.self, from: data) {
            self.settings = savedSettings
        } else {
            self.settings = .default
        }
    }
    
    func updateSettings(_ newSettings: PrayerSettings) {
        settings = newSettings
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }
}

extension Notification.Name {
    static let prayerSettingsChanged = Notification.Name("prayerSettingsChanged")
}
