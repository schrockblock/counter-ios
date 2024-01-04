import SwiftUI
import Tagged
import ComposableArchitecture

typealias QuantityId = Tagged<Quantity, Int>
struct Quantity: Codable, Equatable, Identifiable {
    var id: QuantityId
    @BindingState var symbol = ""
    @BindingState var amount: Int = -1
    @BindingState var units: QuantityUnits = .none
    var isSelected = false
    @BindingState var startTime: Date?
    @BindingState var endTime: Date?
    var amountDescription: String {
        return switch units {
        case .none:
            "Unsupported"
        case .mL:
            "\(amount)mL"
        case .oz:
            "\(amount)oz"
        case .lbs:
            "\(amount)lbs"
        case .time:
            "\(amount)s"
        case .size:
            switch amount {
            case 1: "Tiny"
            case 2: "Small"
            case 3: "Medium"
            case 4: "Big"
            case 5: "Huge"
            default: "Invalid"
            }
        case .length:
            "Unsupported"
        }
    }
    
    init(id: QuantityId, symbol: String = "", amount: Int = -1, units: QuantityUnits = .none, isSelected: Bool = false, startTime: Date? = nil, endTime: Date? = nil) {
        self.id = id
        self.symbol = symbol
        self.amount = amount
        self.units = units
        self.isSelected = isSelected
        self.startTime = startTime
        self.endTime = endTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(QuantityId.self, forKey: .id)
        self._symbol = try container.decode(BindingState<String>.self, forKey: .symbol)
        self._amount = try container.decode(BindingState<Int>.self, forKey: .amount)
        self._units = try container.decode(BindingState<QuantityUnits>.self, forKey: .units)
        self.isSelected = try container.decode(Bool.self, forKey: .isSelected)
        if let binding = try? container.decode(BindingState<Date?>.self, forKey: .startTime) {
            self._startTime = binding
        }
        if let binding = try? container.decode(BindingState<Date?>.self, forKey: .endTime) {
            self._endTime = binding
        }
    }
}

//typealias QuantityBindlessId = Tagged<QuantityBindless, Int>
//struct QuantityBindless: Codable, Equatable, Identifiable {
//    var id: QuantityBindlessId
//    @BindingState var symbol = ""
//    @BindingState var amount: Int = -1
//    @BindingState var units: QuantityUnits = .none
//    var isSelected = false
//    var start: Date? = nil
//    var end: Date? = nil
//}
