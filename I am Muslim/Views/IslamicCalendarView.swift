import SwiftUI

struct IslamicEvent: Identifiable {
    let id = UUID()
    let name: String
    let arabicName: String
    let date: String
    let description: String
    let daysUntil: Int
}

struct SpecialDaysResponse: Codable {
    let code: Int
    let status: String
    let data: [SpecialDay]
}

struct SpecialDay: Codable {
    let month: Int
    let day: Int
    let name: String
}

class IslamicCalendarViewModel: ObservableObject {
    @Published var events: [IslamicEvent] = []
    
    func fetchSpecialDays() {
        guard let url = URL(string: "https://api.aladhan.com/v1/specialDays") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONDecoder().decode(SpecialDaysResponse.self, from: data)
                print("API Response: \(json)") // Log the API response
                DispatchQueue.main.async {
                    let today = Date()
                    self.events = json.data.map { specialDay in
                        let eventDateComponents = DateComponents(year: Calendar.current.component(.year, from: today), month: specialDay.month, day: specialDay.day)
                        let eventDate = Calendar.current.date(from: eventDateComponents) ?? today
                        let daysUntil = Calendar.current.dateComponents([.day], from: today, to: eventDate).day ?? 0
                        print("Event: \(specialDay.name), Date: \(eventDate), Days Until: \(daysUntil)") // Log event details
                        return IslamicEvent(name: specialDay.name, arabicName: "", date: "\(specialDay.month) / \(specialDay.day)", description: "", daysUntil: daysUntil)
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
}

struct IslamicCalendarView: View {
    @StateObject private var viewModel = IslamicCalendarViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.events) { event in
                            EventCard(event: event)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Islamic Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .background(IslamicTheme.primaryGradient.ignoresSafeArea())
        }
        .onAppear {
            viewModel.fetchSpecialDays()
        }
    }
}

struct EventCard: View {
    let event: IslamicEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.arabicName)
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(.white)
                    
                    Text(event.name)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text("\(event.daysUntil)\ndays")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(IslamicTheme.accentColor)
                    .multilineTextAlignment(.center)
            }
            
            Text(event.description)
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
            
            Text(event.date)
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(IslamicTheme.accentColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
