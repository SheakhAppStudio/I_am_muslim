import SwiftUI

struct RamadanView: View {
    @StateObject private var viewModel = RamadanViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
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
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                    .padding(.trailing, 8)
                    
                    Text("Ramadan")
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.2))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Section Title
                        Text("Virtues of Ramadan")
                            .font(.system(.title2, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Virtues Cards
                        VStack(spacing: 15) {
                            VirtueCard(
                                title: "Month of Mercy",
                                description: "Ramadan is the month in which the gates of Paradise are opened, the gates of Hellfire are closed, and the devils are chained.",
                                icon: "heart.circle.fill"
                            )
                            
                            VirtueCard(
                                title: "Night of Power",
                                description: "Laylatul Qadr is better than a thousand months. Seek it in the odd nights of the last ten days.",
                                icon: "moon.stars.fill"
                            )
                            
                            VirtueCard(
                                title: "Forgiveness",
                                description: "Whoever fasts Ramadan out of faith and in the hope of reward, all his previous sins will be forgiven.",
                                icon: "sparkles"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Daily Reminders
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Daily Reminders")
                                .font(.system(.title2, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.dailyReminders) { reminder in
                                ReminderCard(reminder: reminder)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Dua Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Ramadan Duas")
                                .font(.system(.title2, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.ramadanDuas) { dua in
                                DuaCard(dua: dua)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct VirtueCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(IslamicTheme.cardBackground)
                    .frame(width: 50, height: 50)
                    .shadow(color: IslamicTheme.shadowColor, radius: 5, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(IslamicTheme.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .cornerRadius(IslamicTheme.smallCornerRadius)
    }
}

struct ReminderCard: View {
    let reminder: RamadanReminder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: reminder.icon)
                    .foregroundColor(ThemeColors.primary)
                Text(reminder.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.white)
            }
            
            Text(reminder.description)
                .font(.system(.body, design: .serif))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct DuaCard: View {
    let dua: RamadanDua
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(IslamicTheme.cardBackground)
                            .frame(width: 40, height: 40)
                            .shadow(color: IslamicTheme.shadowColor, radius: 5, x: 0, y: 2)
                        
                        Image(systemName: "book.fill")
                            .font(.headline)
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                    
                    Text(dua.title)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(IslamicTheme.accentColor)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(dua.arabicText)
                        .font(.system(.title3, design: .serif))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                    
                    Text(dua.translation)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .cornerRadius(IslamicTheme.smallCornerRadius)
        .animation(.easeInOut, value: isExpanded)
    }
}
