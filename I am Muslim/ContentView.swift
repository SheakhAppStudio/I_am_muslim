//
//  ContentView.swift
//  I am Muslim
//
//  Created by Sheakh Emon on 01/02/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            PrayerView()
                .tabItem {
                    Label("Prayer", systemImage: "moon.stars.fill")
                }
            
            QuranView()
                .tabItem {
                    Label("Quran", systemImage: "book.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(IslamicTheme.accentColor)
        .onAppear {
            // Customize TabBar appearance for iOS 15+
            if #available(iOS 15.0, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithDefaultBackground()
                
                // Set background to match IslamicTheme primaryGradient
                let gradient = CAGradientLayer()
                gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
                gradient.colors = [
                    UIColor(Color(hex: "1F4B6B")).cgColor,
                    UIColor(Color(hex: "366C8F")).cgColor
                ]
                gradient.startPoint = CGPoint(x: 0, y: 0)
                gradient.endPoint = CGPoint(x: 1, y: 1)
                
                let renderer = UIGraphicsImageRenderer(bounds: gradient.bounds)
                let image = renderer.image { context in
                    gradient.render(in: context.cgContext)
                }
                
                appearance.backgroundImage = image
                
                UITabBar.appearance().scrollEdgeAppearance = appearance
                UITabBar.appearance().standardAppearance = appearance
            }
        }
    }
}

#Preview {
    ContentView()
}
