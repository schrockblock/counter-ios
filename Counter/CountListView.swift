import SwiftUI
import ComposableArchitecture

struct CountListView: View {
    let store: StoreOf<CountListReducer> 
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count:  Int(geometry.size.width / 355)), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                        ForEachStore(self.store.scope(state: \.counts, action: CountListReducer.Action.count(_:_:))) { countStore in
                            CountCardView(store: countStore)
                        }
                    }
                }
            }.onAppear(perform: {
                viewStore.send(.onAppear)
            })
        }
    }
}
