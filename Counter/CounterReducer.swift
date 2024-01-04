import SwiftUI
import ComposableArchitecture

func occurrenceList(_ counts: [Count]) -> [Occurrence] {
    var occurrences = [Occurrence]()
    for count in counts {
        if let countOccs = count.occurrences {
            occurrences.append(contentsOf: countOccs)
            if let history = count.history {
                for oldCount in history {
                    if let oldOccs = oldCount.occurrences {
                        occurrences.append(contentsOf: oldOccs)
                    }
                }
            }
        }
    }
    occurrences = occurrences.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    return occurrences
}

class CounterReducer: Reducer {
    struct State: Equatable {
        @PresentationState var editOccurrence: EditOccurrenceReducer.State?
        @PresentationState var newCount: EditReducer.State?
        @PresentationState var editCount: EditReducer.State?
        @PresentationState var chart: CountReducer.State?
        @PresentationState var occurrenceList: OccurrenceListReducer.State?
        var list: CountListReducer.State = .init()
    }
    
    enum Action {
        case addNewTapped
        case didChangeScenePhase
        case saveEdit
        case chartTapped(Count)
        case occurrencesTapped
        case dismissOccurrence, saveOccurrence, cancelOccurrence
        case count(Count.ID, CountReducer.Action)
        case list(CountListReducer.Action)
        case edit(PresentationAction<EditReducer.Action>)
        case editOccurrence(PresentationAction<EditOccurrenceReducer.Action>)
        case chart(PresentationAction<CountReducer.Action>)
        case occurrenceList(PresentationAction<OccurrenceListReducer.Action>)
    }
    
    var body: some ReducerOf<CounterReducer> {
        Scope(state: \.list, action: /Action.list) { 
            CountListReducer()
        }
        Reduce { state, action in
            switch action {
            case .didChangeScenePhase:
                return .send(.list(.onAppear))
            case .chartTapped(let count):
                state.chart = count
            case .occurrencesTapped:
                state.occurrenceList = OccurrenceListReducer.State(occurrences: occurrenceList(state.list.counts.elements))
            case .saveEdit:
                defer {
                    state.editCount = nil
                    state.newCount = nil
                }
                let count: Count
                if let editCount = state.editCount?.count {
                    count = editCount
                } else if let newCount = state.newCount?.count {
                    count = newCount
                } else {
                    break
                }
                return .send(.list(.saveCount(count)))
            case .dismissOccurrence, .cancelOccurrence:
                state.editOccurrence = nil
            case .saveOccurrence:
                defer { state.editOccurrence = nil }
                guard var count = state.editOccurrence?.count, 
                        var occurrence = state.editOccurrence?.occurrence,
                      let quantities = state.editOccurrence?.quantities else { break }
                occurrence.quantities = quantities.elements
                var occurrences = count.occurrences ?? []
                if let index = occurrences.firstIndex(where: { $0.id == occurrence.id }) {
                    occurrences.remove(at: index)
                    occurrences.insert(occurrence, at: index)
                } else { 
                    occurrences.append(occurrence)
                }
                count.occurrences = occurrences
                let copy = count
                return .send(.list(.saveCount(copy)))
            case .addNewTapped:
                state.newCount = EditReducer.State(count: Count(id: Count.ID( state.list.counts.count)))
            case .edit(.presented(.delegate(.saveCount(let count)))):
                return .send(.list(.saveCount(count)))
            case .edit(_): break
            case .editOccurrence(_): break
            case .chart(_): break
            case .list(_): break
//            case .occurrenceList(.delegate(.saveOccurrence(let occurrence))):
//                defer { state.occurrenceList = nil }
//                if let countId = occurrence.countId, let count = state.list.counts[id: countId] {
//                    var occurrences = count.occurrences ?? []
//                    if let index = occurrences.firstIndex(where: { $0.id == occurrence.id }) {
//                        occurrences.remove(at: index)
//                        occurrences.insert(occurrence, at: index)
//                    } else {
//                        occurrences.append(occurrence)
//                    }
//                    count.occurrences = occurrences
//                    let copy = count
//                    return .send(.list(.saveCount(copy)))
//                }
            case .count(let id, .delegate(.newOccurrence(let occurrence))):
                if let count = state.list.counts[id: id] {
                    state.editOccurrence = EditOccurrenceReducer.State(count: count, occurrence: occurrence, quantities: IdentifiedArrayOf(count.quantities))
                }
            case .count(_, .delegate(.editTapped(let count))):
                state.editCount = EditReducer.State(count: count)
            case .count(_, .delegate(.chartTapped(let count))):
                state.chart = count
            case .count(let id, _): 
                if let count = state.list.counts[id: id] {
                    return .send(.list(.saveCount(count)))
                }
            default: break
            }
            
            return .none
        }.ifLet(\.$newCount, action: /Action.edit) {
            EditReducer()
        }.ifLet(\.$editCount, action: /Action.edit) {
            EditReducer()
        }.forEach(\.list.counts, action: /Action.count(_:_:)) {
            CountReducer()
        }.ifLet(\.$editOccurrence, action: /Action.editOccurrence) {
            EditOccurrenceReducer()
        }.ifLet(\.$chart, action: /Action.chart) {
            CountReducer()
        }.ifLet(\.$occurrenceList, action: /Action.occurrenceList) {
            OccurrenceListReducer()
        }
    }
}
