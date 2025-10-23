import Foundation

class DailyDuaViewModel: ObservableObject {
    @Published var morningEveningDuas: [Dua] = []
    @Published var protectionDuas: [Dua] = []
    @Published var dailyLifeDuas: [Dua] = []
    @Published var userDuas: [Dua] = []
    
    private let userDuasKey = "user_saved_duas"
    
    init() {
        setupData()
        loadUserDuas()
    }
    
    private func setupData() {
        // Morning & Evening Duas
        morningEveningDuas = [
            Dua(
                id: 1,
                title: "Morning Remembrance",
                arabicText: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيْرٌ",
                translation: "We have reached the morning and at this very time all sovereignty belongs to Allah. All praise is for Allah. None has the right to be worshipped except Allah, alone, without any partner, to Him belongs all sovereignty and praise, and He is over all things omnipotent."
            ),
            Dua(
                id: 2,
                title: "Evening Remembrance",
                arabicText: "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ للهِ، وَالْحَمْدُ للهِ، لَا إِلَهَ إِلاَّ اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
                translation: "We have reached the evening and at this very time all sovereignty belongs to Allah. All praise is for Allah. None has the right to be worshipped except Allah, alone, without any partner, to Him belongs all sovereignty and praise, and He is over all things omnipotent."
            ),
            Dua(
                id: 3,
                title: "Protection in the Morning & Evening",
                arabicText: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
                translation: "In the name of Allah, Who with His Name nothing can cause harm on earth or in the heavens, and He is the All-Hearing, the All-Knowing. (Recite three times in Arabic)"
            ),
            Dua(
                id: 4,
                title: "Seeking Forgiveness",
                arabicText: "أَسْتَغْفِرُ اللهَ وَأَتُوبُ إِلَيْهِ",
                translation: "I seek the forgiveness of Allah and repent to Him. (Recite 100 times daily)"
            )
        ]
        
        // Protection & Healing Duas
        protectionDuas = [
            Dua(
                id: 5,
                title: "Dua for Protection from All Harm",
                arabicText: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
                translation: "In the name of Allah, with Whose name nothing can cause harm on earth or in the heavens, and He is the All-Hearing, the All-Knowing."
            ),
            Dua(
                id: 6,
                title: "Dua for Anxiety and Sorrow",
                arabicText: "اللَّهُمَّ إِنِّي عَبْدُكَ، ابْنُ عَبْدِكَ، ابْنُ أَمَتِكَ، نَاصِيَتِي بِيَدِكَ، مَاضٍ فِيَّ حُكْمُكَ، عَدْلٌ فِيَّ قَضَاؤُكَ، أَسْأَلُكَ بِكُلِّ اسْمٍ هُوَ لَكَ، سَمَّيْتَ بِهِ نَفْسَكَ، أَوْ أَنْزَلْتَهُ فِي كِتَابِكَ، أَوْ عَلَّمْتَهُ أَحَدًا مِنْ خَلْقِكَ، أَوِ اسْتَأْثَرْتَ بِهِ فِي عِلْمِ الْغَيْبِ عِنْدَكَ، أَنْ تَجْعَلَ الْقُرْآنَ رَبِيعَ قَلْبِي، وَنُورَ صَدْرِي، وَجَلَاءَ حُزْنِي، وَذَهَابَ هَمِّي",
                translation: "O Allah, I am Your servant, son of Your servant, son of Your maidservant, my forelock is in Your hand, Your command over me is forever executed and Your decree over me is just. I ask You by every name belonging to You which You have named Yourself with, or revealed in Your Book, or You taught to any of Your creation, or You have preserved in the knowledge of the Unseen with You, that You make the Quran the life of my heart and the light of my breast, and a departure for my sorrow and a release for my anxiety."
            ),
            Dua(
                id: 7,
                title: "Dua for Healing",
                arabicText: "اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَاسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا",
                translation: "O Allah, Lord of mankind, remove the harm and heal, You are the Healer, there is no healing except Your healing, a healing that leaves no disease behind."
            ),
            Dua(
                id: 8,
                title: "Seeking Refuge from Evil",
                arabicText: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
                translation: "I seek refuge in the perfect words of Allah from the evil of what He has created."
            )
        ]
        
        // Daily Life Duas
        dailyLifeDuas = [
            Dua(
                id: 9,
                title: "Dua Before Eating",
                arabicText: "بِسْمِ اللَّهِ",
                translation: "In the name of Allah."
            ),
            Dua(
                id: 10,
                title: "Dua After Eating",
                arabicText: "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا، وَرَزَقَنِيهِ، مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ",
                translation: "All praise is for Allah who fed me this and provided it for me without any might nor power from myself."
            ),
            Dua(
                id: 11,
                title: "Dua Before Sleeping",
                arabicText: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
                translation: "In Your name, O Allah, I die and I live."
            ),
            Dua(
                id: 12,
                title: "Dua Upon Waking Up",
                arabicText: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا، وَإِلَيْهِ النُّشُورُ",
                translation: "All praise is for Allah who gave us life after having taken it from us and unto Him is the resurrection."
            ),
            Dua(
                id: 13,
                title: "Dua When Entering the Home",
                arabicText: "بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا",
                translation: "In the name of Allah we enter, in the name of Allah we leave, and upon our Lord we depend."
            ),
            Dua(
                id: 14,
                title: "Dua for Parents",
                arabicText: "رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا",
                translation: "My Lord, have mercy upon them as they brought me up when I was small."
            ),
            Dua(
                id: 15,
                title: "Dua for Seeking Knowledge",
                arabicText: "رَبِّ زِدْنِي عِلْمًا",
                translation: "My Lord, increase me in knowledge."
            )
        ]
    }
    
    // MARK: - User Duas Management
    
    func loadUserDuas() {
        if let data = UserDefaults.standard.data(forKey: userDuasKey),
           let savedDuas = try? JSONDecoder().decode([Dua].self, from: data) {
            userDuas = savedDuas
        }
    }
    
    func saveUserDuas() {
        if let encoded = try? JSONEncoder().encode(userDuas) {
            UserDefaults.standard.set(encoded, forKey: userDuasKey)
        }
    }
    
    func addUserDua(title: String, arabicText: String, translation: String) {
        let newId = (userDuas.map { $0.id }.max() ?? 0) + 1
        let newDua = Dua(id: newId, title: title, arabicText: arabicText, translation: translation)
        userDuas.append(newDua)
        saveUserDuas()
    }
    
    func deleteDua(id: Int) {
        userDuas.removeAll { $0.id == id }
        saveUserDuas()
    }
}

// Data Models
struct Dua: Identifiable, Codable {
    let id: Int
    let title: String
    let arabicText: String
    let translation: String
}
