import SwiftUI

enum QuantityUnits: String, Codable, CaseIterable {
    case none
    case mL
    case oz
    case lbs
    case time
    case size
    case length
}

enum IntervalUnits: String, Codable, CaseIterable {
    case none
    case day
    case week
    case month
    case year
}
