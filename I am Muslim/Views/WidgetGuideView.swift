import SwiftUI

struct WidgetGuideView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Prayer Times Widget")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "C3934B"))
            
            VStack(alignment: .leading, spacing: 16) {
                guideStep(number: "1", text: "Long press any empty area on your home screen")
                guideStep(number: "2", text: "Tap the '+' button in the top left corner")
                guideStep(number: "3", text: "Search for 'I am Muslim' or scroll to find it")
                guideStep(number: "4", text: "Choose your preferred widget size")
                guideStep(number: "5", text: "Tap 'Add Widget' to finish")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            
            Spacer()
            
            Text("The widget will automatically update with your prayer times throughout the day")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
    
    private func guideStep(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color(hex: "C3934B")))
            
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    WidgetGuideView()
}
