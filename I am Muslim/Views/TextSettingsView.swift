import SwiftUI

struct TextSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var quranService: QuranReadingService
    
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
                    VStack(spacing: 24) {
                        // Arabic Text Size
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Arabic Text Size")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                            
                            HStack {
                                Button(action: { adjustArabicSize(-2) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(IslamicTheme.accentColor)
                                        .imageScale(.large)
                                }
                                
                                Slider(value: $quranService.arabicTextSize, in: 16...40)
                                    .accentColor(IslamicTheme.accentColor)
                                
                                Button(action: { adjustArabicSize(2) }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(IslamicTheme.accentColor)
                                        .imageScale(.large)
                                }
                            }
                            
                            // Preview
                            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                                .font(.custom(quranService.currentArabicFont.rawValue, size: quranService.arabicTextSize))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(16)
                        
                        // Translation Text Size
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Translation Text Size")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                            
                            HStack {
                                Button(action: { adjustTranslationSize(-1) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(IslamicTheme.accentColor)
                                        .imageScale(.large)
                                }
                                
                                Slider(value: $quranService.translationTextSize, in: 12...24)
                                    .accentColor(IslamicTheme.accentColor)
                                
                                Button(action: { adjustTranslationSize(1) }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(IslamicTheme.accentColor)
                                        .imageScale(.large)
                                }
                            }
                            
                            // Preview
                            Text("In the name of Allah, the Entirely Merciful, the Especially Merciful")
                                .font(.system(size: quranService.translationTextSize, design: .serif))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(16)
                        
                        // Arabic Font Style
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Arabic Font Style")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                            
                            ForEach(ArabicFont.allCases, id: \.self) { font in
                                Button(action: {
                                    quranService.updateArabicFont(font)
                                }) {
                                    HStack {
                                        Text(font.displayName)
                                            .font(.system(.body, design: .serif))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if quranService.currentArabicFont == font {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(IslamicTheme.accentColor)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(16)
                    }
                    .padding()
                }
            }
            .navigationTitle("Text Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(IslamicTheme.accentColor)
                }
            }
        }
    }
    
    private func adjustArabicSize(_ delta: Double) {
        let newSize = quranService.arabicTextSize + delta
        quranService.arabicTextSize = min(max(newSize, 16), 40)
    }
    
    private func adjustTranslationSize(_ delta: Double) {
        let newSize = quranService.translationTextSize + delta
        quranService.translationTextSize = min(max(newSize, 12), 24)
    }
}
