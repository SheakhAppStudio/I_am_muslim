import Foundation

// MARK: - Radio Response
struct RadioResponse: Codable {
    let radios: [RadioStation]
    
    enum CodingKeys: String, CodingKey {
        case radios = "radios"
    }
}

// MARK: - Radio Station
struct RadioStation: Identifiable, Codable {
    let id: Int
    let name: String
    let url: String
    let recentDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case recentDate = "recent_date"
    }
    
    // Computed property to extract language from name if available
    var language: String? {
        // Common language patterns in Arabic names
        let patterns = [
            "باللغة\\s+([^\\s]+)", // matches "باللغة X"
            "بلغة\\s+([^\\s]+)",   // matches "بلغة X"
            "\\(([^)]+)\\)"        // matches anything in parentheses
        ]
        
        for pattern in patterns {
            if let range = name.range(of: pattern, options: .regularExpression) {
                let match = String(name[range])
                return match
                    .replacingOccurrences(of: "باللغة ", with: "")
                    .replacingOccurrences(of: "بلغة ", with: "")
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
}
