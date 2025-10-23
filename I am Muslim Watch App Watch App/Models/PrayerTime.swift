//
//  PrayerTime.swift
//  I am Muslim Watch App Watch App
//
//  Created by Cascade AI on 25/04/2025.
//

import Foundation

struct PrayerTime: Identifiable, Codable {
    let id = UUID()
    let name: String
    let time: Date
    let arabicName: String
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: time)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: time)
    }
    
    var timeRemaining: String {
        let calendar = Calendar.current
        let now = Date()
        
        if now > time {
            // If it's past this prayer time, calculate time until next occurrence
            var nextOccurrence = time
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: time) {
                nextOccurrence = tomorrow
            }
            
            let components = calendar.dateComponents([.hour, .minute], from: now, to: nextOccurrence)
            guard let hours = components.hour, let minutes = components.minute else { return "Passed" }
            
            if hours > 0 {
                return "\(hours)h \(minutes)m until next"
            } else {
                return "\(minutes)m until next"
            }
        }
        
        let components = calendar.dateComponents([.hour, .minute], from: now, to: time)
        guard let hours = components.hour, let minutes = components.minute else { return "" }
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct PrayerAPIResponse: Codable {
    let code: Int
    let status: String
    let data: PrayerData
}

struct PrayerData: Codable {
    let timings: PrayerTimings
    let date: DateInfo
    let meta: Meta?
}

struct Meta: Codable {
    let latitude: Double?
    let longitude: Double?
    let timezone: String?
}

struct PrayerTimings: Codable {
    let Fajr: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
    
    private enum CodingKeys: String, CodingKey {
        case Fajr, Dhuhr, Asr, Maghrib, Isha
    }
}

struct DateInfo: Codable {
    let readable: String
    let timestamp: String?
}
