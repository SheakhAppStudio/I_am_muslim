import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            PrayerView()
                .tabItem {
                    Image(systemName: "moon.stars.fill")
                    Text("Prayer")
                }
                .tag(1)
            
            QuranView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Quran")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
}
