import SwiftUI
import ComposableArchitecture

struct EditCountView: View {
    let store: StoreOf<EditReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0.count }) { viewStore in
            VStack {
                TextField("Count title", text: viewStore.binding(get: \.title, send: { .set(\.count.$title, $0) }))
                Picker("Per time interval", selection: viewStore.binding(get: \.interval, send: { .set(\.count.$interval, $0) })) {
                    ForEach(IntervalUnits.allCases, id: \.self) {
                        Text($0.rawValue).tag(Optional($0))
                    }
                }
                
                Button("Add Quantity") {
                    viewStore.send(.addQuantity)
                }

                List {
                    ForEachStore(
                        store.scope(state: \.count.quantities, action: EditReducer.Action.quantity)
                    ) { store in
                        QuantityView(store: store)
                    }
                }
            }
        }
    }
}
