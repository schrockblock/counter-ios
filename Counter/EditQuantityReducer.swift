import SwiftUI
import ComposableArchitecture
import Tagged

class EditQuantityReducer: Reducer {
    typealias State = Quantity
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<EditQuantityReducer> {
        BindingReducer()
            .onChange(of: \.startTime) { oldValue, newValue in
                Reduce { state, action in
                    if let start = newValue, let end = state.endTime {
                        state.amount = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
                    }
                    return .none
                }
            }
            .onChange(of: \.endTime) { oldValue, newValue in
                Reduce { state, action in
                    if let start = state.startTime, let end = newValue {
                        state.amount = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
                    }
                    return .none
                }
            }
    }
}
