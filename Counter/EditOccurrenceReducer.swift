import SwiftUI
import ComposableArchitecture

class EditOccurrenceReducer: Reducer {
    struct State: Equatable {
        var count: Count
        var occurrence: Occurrence
        var quantities: IdentifiedArrayOf<EditQuantityReducer.State>
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case toggledQuantity(EditQuantityReducer.State)
        case quantity(EditQuantityReducer.State.ID, EditQuantityReducer.Action)
        case setDate(Date)
    }
    
    var body: some ReducerOf<EditOccurrenceReducer> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if var quantity = state.quantities.first, state.quantities.count == 1 && quantity.isSelected == false {
                    quantity.isSelected = true
                    state.quantities[id: quantity.id] = quantity
                }
            case .toggledQuantity(var quantity):
                quantity.isSelected.toggle()
                state.quantities[id: quantity.id] = quantity
            case .setDate(let date):
                state.occurrence.date = date
            case .binding(_):
                break
            case .quantity(_, _):
                break
            }
            return .none
        }.forEach(\.quantities, action: /Action.quantity(_:_:)) {
            EditQuantityReducer()
        }
    }
}
