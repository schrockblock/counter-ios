import SwiftUI
import ComposableArchitecture

struct CountReducer: Reducer {
    typealias State = Count
    
    enum Action {
        case editTapped
        case chartTapped
        case increment, decrement
        case delegate(Delegate)
        
        enum Delegate {
            case editTapped(Count)
            case chartTapped(Count)
            case updateCount(Count)
            case newOccurrence(Occurrence)
        }
    }
    
    var body: some ReducerOf<CountReducer> {
        Reduce { state, action in
            switch action {
            case .chartTapped:
                return .send(.delegate(.chartTapped(state)))
            case .editTapped:
                return .send(.delegate(.editTapped(state)))
            case .increment:
                let newOccurrence = Occurrence(id: Occurrence.ID(rawValue: Int.random(in: 0..<Int.max)), date: Date())
                if state.quantities.isEmpty {
                    if state.occurrences != nil {
                        state.occurrences?.append(newOccurrence)
                    } else {
                        state.occurrences = [newOccurrence]
                    }
                } else {
                    return .send(.delegate(.newOccurrence(newOccurrence)))
                }
            case .decrement:
                if state.quantities.isEmpty {
                    let _ = state.occurrences?.popLast()
                } else {
                    
                }
            case .delegate(_): break
            }
            return .none
        }
    }
}
