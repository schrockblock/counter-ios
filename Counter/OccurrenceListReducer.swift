//
//  OccurrenceListReducer.swift
//  Counter
//
//  Created by Elliot Schrock on 11/16/23.
//

import Foundation
import ComposableArchitecture

class OccurrenceListReducer: Reducer {
    struct State: Equatable {
        @PresentationState var editOccurrence: EditOccurrenceReducer.State?
        var occurrences: [Occurrence]
    }
    
    enum Action {
        case startEdit(Occurrence)
        case dismissOccurrence, saveOccurrence, cancelOccurrence
        case editOccurrence(PresentationAction<EditOccurrenceReducer.Action>)
        case delegate(Delegate)
        
        enum Delegate {
            case saveOccurrence(Occurrence)
        }
    }
    
    var body: some ReducerOf<OccurrenceListReducer> {
        Reduce { state, action in
            switch action {
            case .saveOccurrence:
                defer { state.editOccurrence = nil }
                guard let occurrence = state.editOccurrence?.occurrence else { break }
                return .send(.delegate(.saveOccurrence(occurrence)))
            case .dismissOccurrence, .cancelOccurrence:
                state.editOccurrence = nil
            default: break
            }
            return .none
        }.ifLet(\.$editOccurrence, action: /Action.editOccurrence) {
            EditOccurrenceReducer()
        }
    }
}
