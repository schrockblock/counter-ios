import SwiftUI
import ComposableArchitecture

struct QuantityView: View {
    let store: StoreOf<EditQuantityReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                TextField("Emoji", text: viewStore.$symbol)
                Spacer()
                Picker("Units", selection: viewStore.$units) {
                    ForEach(QuantityUnits.allCases, id: \.self) {
                        Text($0.rawValue).tag(Optional($0))
                    }
                }
            }
        }
    }
}
