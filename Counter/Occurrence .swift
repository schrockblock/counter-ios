import SwiftUI
import Tagged

struct Occurrence: Codable, Equatable, Identifiable {
    typealias ID = Tagged<Occurrence, Int>
    var id: ID
    var symbol: String?
    var date: Date?
    var countId: CountId?
    var countName: String?
    var quantities: [EditQuantityReducer.State]?
}

extension Date {
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.calendar?.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateTimeStyle = .numeric
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    var ago: String {
        guard abs(timeIntervalSinceNow) > 60 else {
            return "now"
        }
        
        let text = Self.relativeFormatter.localizedString(for: self, relativeTo: Date())
        return text
            .replacingOccurrences(of: "ago", with: "")
            .replacingOccurrences(of: "min", with: "m")
            .replacingOccurrences(of: "hr", with: "h")
            .replacingOccurrences(of: "day", with: "d")
            .replacingOccurrences(of: "wk", with: "w")
            .replacingOccurrences(of: "yr", with: "y")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}
