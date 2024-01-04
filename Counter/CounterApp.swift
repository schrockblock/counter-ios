import SwiftUI
import ComposableArchitecture


var encoder = JSONEncoder()
var decoder = JSONDecoder()

@main
struct CounterApp: App {
    
    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: Store(initialState: CounterReducer.State(), reducer: { CounterReducer()._printChanges() }))
        }
    }
}
