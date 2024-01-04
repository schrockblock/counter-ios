import SwiftUI
import ComposableArchitecture

class EditReducer: Reducer {
    struct State: Equatable {
        @BindingState var count: Count
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case addQuantity
        case deleteQuantity
        case delegate(Delegate)
        case quantity(EditQuantityReducer.State.ID, EditQuantityReducer.Action)
        
        enum Delegate: Equatable {
            case saveCount(Count)
        }
    }
    
    var body: some ReducerOf<EditReducer> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(_): break
            case .addQuantity:
                let newId = state.count.quantities.count
                state.count.quantities.append(EditQuantityReducer.State(id: EditQuantityReducer.State.ID(newId)))
            case .deleteQuantity:
                break
            case .delegate(_), .quantity(_, _): break
            }
            return .none
        }.forEach(\.count.quantities, action: /Action.quantity) { 
            EditQuantityReducer()
        }
    }
}
