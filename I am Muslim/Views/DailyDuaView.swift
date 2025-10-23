import SwiftUI

struct DailyDuaView: View {
    @StateObject private var viewModel = DailyDuaViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showAddDuaSheet = false
    @State private var newDuaTitle = ""
    @State private var newDuaArabicText = ""
    @State private var newDuaTranslation = ""
    
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
                    
                    Text("Daily Duas")
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showAddDuaSheet = true }) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                
                // Tab Selection
                HStack(spacing: 0) {
                    TabButton(title: "Essential Duas", isSelected: selectedTab == 0) {
                        withAnimation { selectedTab = 0 }
                    }
                    
                    TabButton(title: "My Duas", isSelected: selectedTab == 1) {
                        withAnimation { selectedTab = 1 }
                    }
                }
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.15))
                
                ScrollView {
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            // Essential Duas Section
                            VStack(spacing: 20) {
                                // Section Title
                                Text("Daily Essential Duas")
                                    .font(.system(.title2, design: .serif))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                // Virtues Cards
                                VStack(spacing: 15) {
                                    VirtueCard(
                                        title: "Importance of Dua",
                                        description: "Dua is the essence of worship. The Prophet Muhammad (PBUH) said: 'Dua is worship.'",
                                        icon: "heart.circle.fill"
                                    )
                                    
                                    VirtueCard(
                                        title: "Best Times for Dua",
                                        description: "The last third of the night, between adhan and iqamah, while fasting, and during prostration are among the best times for making dua.",
                                        icon: "clock.fill"
                                    )
                                    
                                    VirtueCard(
                                        title: "Etiquette of Dua",
                                        description: "Begin with praise of Allah, send blessings upon the Prophet (PBUH), raise your hands, face the qiblah, and have certainty that Allah will respond.",
                                        icon: "hand.raised.fill"
                                    )
                                }
                                .padding(.horizontal)
                                
                                // Daily Duas
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Morning & Evening Duas")
                                        .font(.system(.title2, design: .serif))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    ForEach(viewModel.morningEveningDuas) { dua in
                                        DailyDuaCard(dua: dua)
                                            .padding(.horizontal)
                                    }
                                }
                                
                                // Protection Duas
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Protection & Healing Duas")
                                        .font(.system(.title2, design: .serif))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    ForEach(viewModel.protectionDuas) { dua in
                                        DailyDuaCard(dua: dua)
                                            .padding(.horizontal)
                                    }
                                }
                                
                                // Daily Life Duas
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Daily Life Duas")
                                        .font(.system(.title2, design: .serif))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    ForEach(viewModel.dailyLifeDuas) { dua in
                                        DailyDuaCard(dua: dua)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        } else {
                            // My Duas Section
                            VStack(spacing: 20) {
                                if viewModel.userDuas.isEmpty {
                                    VStack(spacing: 15) {
                                        Image(systemName: "square.and.pencil")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(.top, 40)
                                        
                                        Text("No Personal Duas Yet")
                                            .font(.system(.title3, design: .serif))
                                            .foregroundColor(.white)
                                        
                                        Text("Add your own duas to remember and reflect on them later.")
                                            .font(.system(.body, design: .serif))
                                            .foregroundColor(.white.opacity(0.7))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                        
                                        Button(action: { showAddDuaSheet = true }) {
                                            HStack {
                                                Image(systemName: "plus.circle.fill")
                                                Text("Add Your First Dua")
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(IslamicTheme.accentColor)
                                            .cornerRadius(25)
                                            .foregroundColor(.white)
                                        }
                                        .padding(.top, 10)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    Text("My Personal Duas")
                                        .font(.system(.title2, design: .serif))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    ForEach(viewModel.userDuas) { dua in
                                        UserDuaCard(dua: dua, onDelete: {
                                            viewModel.deleteDua(id: dua.id)
                                        })
                                        .padding(.horizontal)
                                    }
                                    
                                    Button(action: { showAddDuaSheet = true }) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Add Another Dua")
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(IslamicTheme.accentColor)
                                        .cornerRadius(25)
                                        .foregroundColor(.white)
                                    }
                                    .padding(.top, 10)
                                    .padding(.bottom, 30)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddDuaSheet) {
            AddDuaView(
                isPresented: $showAddDuaSheet,
                onSave: { title, arabicText, translation in
                    viewModel.addUserDua(title: title, arabicText: arabicText, translation: translation)
                }
            )
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                // Indicator
                Rectangle()
                    .fill(isSelected ? IslamicTheme.accentColor : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DuaVirtueCard: View {
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

struct DailyDuaCard: View {
    let dua: Dua
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

struct UserDuaCard: View {
    let dua: Dua
    let onDelete: () -> Void
    @State private var isExpanded = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(IslamicTheme.cardBackground)
                            .frame(width: 40, height: 40)
                            .shadow(color: IslamicTheme.shadowColor, radius: 5, x: 0, y: 2)
                        
                        Image(systemName: "heart.fill")
                            .font(.headline)
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                    
                    Text(dua.title)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .font(.subheadline)
                            .foregroundColor(.red.opacity(0.7))
                    }
                    .padding(.trailing, 8)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(IslamicTheme.accentColor)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    if !dua.arabicText.isEmpty {
                        Text(dua.arabicText)
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                    }
                    
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
        .alert("Delete Dua", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this dua? This action cannot be undone.")
        }
    }
}

struct AddDuaView: View {
    @Binding var isPresented: Bool
    let onSave: (String, String, String) -> Void
    
    @State private var title = ""
    @State private var arabicText = ""
    @State private var translation = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                IslamicTheme.primaryGradient
                    .ignoresSafeArea()
                    .overlay(
                        IslamicPatternView(color: .white, opacity: 0.05)
                            .ignoresSafeArea()
                    )
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Add Your Personal Dua")
                            .font(.system(.title2, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                            
                            TextField("", text: $title)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .accentColor(IslamicTheme.accentColor)
                                .overlay(
                                    Group {
                                        if title.isEmpty {
                                            Text("e.g., Dua for Guidance")
                                                .foregroundColor(.white.opacity(0.5))
                                                .padding(.leading, 20)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                )
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Arabic Text (Optional)")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                            
                            TextEditor(text: $arabicText)
                                .frame(height: 100)
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .accentColor(IslamicTheme.accentColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if arabicText.isEmpty {
                                            Text("Enter Arabic text if available")
                                                .foregroundColor(.white.opacity(0.5))
                                                .padding(.leading, 15)
                                                .padding(.top, 18)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                )
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Translation/Meaning")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                            
                            TextEditor(text: $translation)
                                .frame(height: 150)
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .accentColor(IslamicTheme.accentColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if translation.isEmpty {
                                            Text("Enter the meaning or your personal dua")
                                                .foregroundColor(.white.opacity(0.5))
                                                .padding(.leading, 15)
                                                .padding(.top, 18)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                )
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            if !title.isEmpty && !translation.isEmpty {
                                onSave(title, arabicText, translation)
                                isPresented = false
                            }
                        }) {
                            Text("Save Dua")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    (!title.isEmpty && !translation.isEmpty) ?
                                    IslamicTheme.accentColor :
                                    IslamicTheme.accentColor.opacity(0.5)
                                )
                                .cornerRadius(10)
                        }
                        .disabled(title.isEmpty || translation.isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(IslamicTheme.accentColor)
            )
        }
    }
}

// Placeholder extension removed to avoid conflicts
