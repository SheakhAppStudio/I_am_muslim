import SwiftUI

// Main View
struct BackgroundPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            BackgroundContent()
                .navigationTitle("Background Style")
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
}

// Content View
private struct BackgroundContent: View {
    @EnvironmentObject private var quranService: QuranReadingService
    
    var body: some View {
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
                    ForEach(0..<QuranCardStyle.styles.count, id: \.self) { index in
                        StyleButton(index: index)
                    }
                }
                .padding()
            }
        }
    }
}

// Style Button
private struct StyleButton: View {
    @EnvironmentObject private var quranService: QuranReadingService
    @Environment(\.dismiss) private var dismiss
    let index: Int
    
    private var style: QuranCardStyle {
        QuranCardStyle.styles[index]
    }
    
    var body: some View {
        Button(action: {
            quranService.updateCardStyle(index)
            dismiss()
        }) {
            StylePreview(style: style, isSelected: quranService.selectedCardStyleIndex == index)
        }
    }
}

// Style Preview
private struct StylePreview: View {
    @EnvironmentObject private var quranService: QuranReadingService
    let style: QuranCardStyle
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            // Style name
            HStack {
                Text(style.name)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(IslamicTheme.accentColor)
                }
            }
            
            // Preview text
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.custom(quranService.currentArabicFont.rawValue, size: quranService.arabicTextSize))
                .foregroundColor(style.textColor)
            
            Text("In the name of Allah, the Entirely Merciful, the Especially Merciful")
                .font(.system(.body, design: .serif))
                .foregroundColor(style.translationColor)
        }
        .padding()
        .background(style.background)
        .cornerRadius(12)
    }
}
