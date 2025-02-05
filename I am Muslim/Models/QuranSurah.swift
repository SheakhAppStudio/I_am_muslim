import Foundation

struct QuranSurah: Identifiable, Codable {
    var id: UUID
    let number: Int
    let name: String
    let arabicName: String
    let verses: Int
    var duration: Int // in seconds
    
    init(number: Int, name: String, arabicName: String, verses: Int, duration: Int) {
        self.id = UUID()
        self.number = number
        self.name = name
        self.arabicName = arabicName
        self.verses = verses
        self.duration = duration
    }
    
    var durationFormatted: String {
        let minutes = duration / 60
        let seconds = duration % 60
        if minutes > 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return String(format: "%d:%02d:%02d", hours, remainingMinutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct QuranVerse: Identifiable {
    let id = UUID()
    let number: Int
    let surahNumber: Int
    let text: String
    let audioUrl: String
    
    init(number: Int, surahNumber: Int, text: String) {
        self.number = number
        self.surahNumber = surahNumber
        self.text = text
        // Using Mishary Rashid Alafasy's recitation (identifier: 7)
        self.audioUrl = "https://verses.quran.com/Alafasy/mp3/\(String(format: "%03d", surahNumber))_\(String(format: "%03d", number)).mp3"
    }
}
