import SwiftUI

struct PrayerSettingsView: View {
    @ObservedObject private var settingsManager = PrayerSettingsManager.shared
    @State private var showingCalculationMethodSheet = false
    @State private var showingAsrCalculationSheet = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PrayerTimesViewModel.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Method Settings
                VStack(spacing: 12) {
                    SettingsButton(
                        title: "Calculation Method",
                        value: settingsManager.settings.calculationMethod.name,
                        icon: "globe"
                    ) {
                        showingCalculationMethodSheet = true
                    }
                    
                    Divider()
                    
                    SettingsButton(
                        title: "Asr Calculation",
                        value: settingsManager.settings.asrCalculation.name,
                        icon: "sun.max"
                    ) {
                        showingAsrCalculationSheet = true
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color(white: 0.15) : .white)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                // Time Adjustments
                VStack(alignment: .leading, spacing: 16) {
                    Text("Time Adjustments")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        TimeAdjustmentRow(title: "Fajr", value: $settingsManager.settings.fajrAdjustment)
                        TimeAdjustmentRow(title: "Sunrise", value: $settingsManager.settings.sunriseAdjustment)
                        TimeAdjustmentRow(title: "Dhuhr", value: $settingsManager.settings.dhuhrAdjustment)
                        TimeAdjustmentRow(title: "Asr", value: $settingsManager.settings.asrAdjustment)
                        TimeAdjustmentRow(title: "Maghrib", value: $settingsManager.settings.maghribAdjustment)
                        TimeAdjustmentRow(title: "Isha", value: $settingsManager.settings.ishaAdjustment)
                        TimeAdjustmentRow(title: "Imsak", value: $settingsManager.settings.imsakAdjustment)
                    }
                    .padding()
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color(white: 0.15) : .white)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Prayer Settings")
        .sheet(isPresented: $showingCalculationMethodSheet) {
            CalculationMethodSheet(
                selection: $settingsManager.settings.calculationMethod,
                onMethodSelected: { method in
                    Task {
                        print("Calculation method changed to: \(method.name)")
                        await viewModel.refreshPrayerTimes(forceRefresh: true)
                    }
                }
            )
        }
        .sheet(isPresented: $showingAsrCalculationSheet) {
            AsrCalculationSheet(
                selection: $settingsManager.settings.asrCalculation,
                onMethodSelected: { method in
                    Task {
                        print("Asr calculation method changed to: \(method.name)")
                        await viewModel.refreshPrayerTimes(forceRefresh: true)
                    }
                }
            )
        }
    }
}

struct SettingsButton: View {
    let title: String
    let value: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.primary)
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct TimeAdjustmentRow: View {
    let title: String
    @Binding var value: Int
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: { if value > -30 { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(value > -30 ? .blue : .gray.opacity(0.3))
                }
                
                Text("\(value)")
                    .monospacedDigit()
                    .frame(width: 30)
                    .foregroundColor(value == 0 ? .primary : .blue)
                
                Button(action: { if value < 30 { value += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(value < 30 ? .blue : .gray.opacity(0.3))
                }
            }
        }
    }
}

struct CalculationMethodSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: PrayerSettings.CalculationMethod
    let onMethodSelected: (PrayerSettings.CalculationMethod) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(PrayerSettings.CalculationMethod.allCases, id: \.self) { method in
                    Button(action: {
                        selection = method
                        onMethodSelected(method)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(method.name)
                                    .foregroundColor(.primary)
                                Text(method.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selection == method {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Calculation Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AsrCalculationSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: PrayerSettings.AsrCalculation
    let onMethodSelected: (PrayerSettings.AsrCalculation) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(PrayerSettings.AsrCalculation.allCases, id: \.self) { method in
                    Button(action: {
                        selection = method
                        onMethodSelected(method)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(method.name)
                                    .foregroundColor(.primary)
                                Text(method.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selection == method {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Asr Calculation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
