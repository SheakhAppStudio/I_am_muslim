import Foundation

class RamadanViewModel: ObservableObject {

    @Published var dailyReminders: [RamadanReminder] = []
    @Published var ramadanDuas: [RamadanDua] = []
    
    init() {
        setupData()
    }
    
    private func setupData() {
        // Sample data - In a real app, this would come from a database or API
        dailyReminders = [
            RamadanReminder(
                id: 1,
                title: "Pre-dawn Meal (Suhoor)",
                description: "Wake up before Fajr for Suhoor. It's a blessed meal that helps sustain your fast.",
                icon: "sunrise.fill"
            ),
            RamadanReminder(
                id: 2,
                title: "Taraweeh Prayer",
                description: "Join the special nightly prayers during Ramadan to earn extra rewards.",
                icon: "moon.stars.fill"
            ),
            RamadanReminder(
                id: 3,
                title: "Quran Reading",
                description: "Try to read and reflect on at least one page of the Quran daily.",
                icon: "book.fill"
            ),
            RamadanReminder(
                id: 4,
                title: "Acts of Charity",
                description: "Remember to help those in need. Ramadan is the month of giving.",
                icon: "heart.fill"
            )
        ]
        
        ramadanDuas = [
            RamadanDua(
                id: 1,
                title: "Dua for Beginning the Fast",
                arabicText: "نَوَيْتُ صَوْمَ غَدٍ مِنْ شَهْرِ رَمَضَانَ",
                translation: "I intend to keep the fast for tomorrow in the month of Ramadan"
            ),
            RamadanDua(
                id: 2,
                title: "Dua for Breaking the Fast",
                arabicText: "اللَّهُمَّ إِنِّي لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ",
                translation: "O Allah, I fasted for You and I believe in You and I break my fast with Your sustenance"
            ),
            RamadanDua(
                id: 3,
                title: "Dua for Laylatul Qadr",
                arabicText: "اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي",
                translation: "O Allah, You are Most Forgiving, and You love forgiveness; so forgive me"
            ),
            RamadanDua(
                id: 4,
                title: "Dua for Seeking Forgiveness",
                arabicText: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
                translation: "Our Lord, grant us good in this world and good in the Hereafter, and protect us from the torment of the Fire"
            ),
            RamadanDua(
                id: 5,
                title: "Dua for Last Ten Nights",
                arabicText: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
                translation: "O Allah, help me to remember You, thank You, and worship You in the best manner"
            ),
            RamadanDua(
                id: 6,
                title: "Dua for Accepting Fasts",
                arabicText: "اللَّهُمَّ تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ",
                translation: "O Allah, accept from us. Indeed, You are the All-Hearing, the All-Knowing"
            ),
            RamadanDua(
                id: 1,
                title: "Dua for Beginning the Fast",
                arabicText: "نَوَيْتُ صَوْمَ غَدٍ مِنْ شَهْرِ رَمَضَانَ",
                translation: "I intend to keep the fast for tomorrow in the month of Ramadan"
            ),
            RamadanDua(
                id: 2,
                title: "Dua for Breaking the Fast",
                arabicText: "اللَّهُمَّ إِنِّي لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ",
                translation: "O Allah, I fasted for You and I believe in You and I break my fast with Your sustenance"
            ),
            RamadanDua(
                id: 3,
                title: "Dua for Laylatul Qadr",
                arabicText: "اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي",
                translation: "O Allah, You are Most Forgiving, and You love forgiveness; so forgive me"
            )
        ]
        

    }
}

// Data Models
struct RamadanReminder: Identifiable {
    let id: Int
    let title: String
    let description: String
    let icon: String
}

struct RamadanDua: Identifiable {
    let id: Int
    let title: String
    let arabicText: String
    let translation: String
}
