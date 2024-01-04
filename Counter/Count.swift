import SwiftUI
import Tagged
import ComposableArchitecture

typealias CountId = Tagged<Count, Int>
struct Count: Codable, Equatable, Identifiable {
    var id: CountId
    @BindingState var title: String = ""
    var name: String {
        get { title }
        set { title = newValue }
    }
    @BindingState var interval: IntervalUnits?
    var intervalStart: Date?
    var quantities: IdentifiedArrayOf<EditQuantityReducer.State> = IdentifiedArray(uniqueElements: [EditQuantityReducer.State]())
    
    var occurrences: [Occurrence]? = [Occurrence]()
    var history: [Count]?
    
    var avg: String? {
        if let history, history.count > 0 {
            return "\(history.reduce(0, { $0 + ($1.occurrences?.count ?? 0) }) / history.count)"
        }
        return nil
    }
    
    func startOfThisInterval() -> Date? {
        if let interval {
            let cal = Calendar.current
            switch interval {
            case .none:
                return nil
            case .day:
                return cal.startOfDay(for: Date())
            case .week:
                var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date())
                comps.weekday = 2 // Monday
                return cal.date(from: comps)!
            case .month:
                let comps = cal.dateComponents([.year, .month], from: Date())
                return cal.date(from: comps)!
            case .year:
                let comps = cal.dateComponents([.year], from: Date())
                return cal.date(from: comps)!
            }
        }
        return nil
    }
    
    func shouldAdvance() -> Bool {
        if let lastStart = intervalStart, let cutoffDate = startOfThisInterval() {
            return lastStart < cutoffDate
        }
        return false
    }
    
    func advancedOneInterval() -> Count {
        var newHistory = history ?? []
        var oldCount = self
        if !(oldCount.occurrences?.isEmpty ?? true) {
            oldCount.history = nil
            newHistory.append(oldCount)
        }
        
        let newStart = startOfThisInterval()
        
        return Count(id: id, title: title, interval: interval, intervalStart: newStart, quantities: quantities, occurrences: [], history: newHistory)
    }
}
