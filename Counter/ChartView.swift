//
//  ChartView.swift
//  Counter
//
//  Created by Elliot Schrock on 8/30/23.
//

import SwiftUI
import Charts
import ComposableArchitecture

struct ChartView: View {
    static let timeAxisTitle = "Time"
    let store: Store<CountReducer.State, CountReducer.Action>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack {
                    Text(viewStore.name)
                    Chart(viewStore.history ?? []) { oldCount in
                        BarMark(x: .value(ChartView.timeAxisTitle, oldCount.intervalStart!), y: .value("Count", oldCount.occurrences?.count ?? 0))
                    }
                    Spacer()
                }
            }
//            .navigationDestination(store: store.scope(state: \.$editCount, action: { CountReducer.Action.edit($0) })) { editStore in
//                NavigationStack {
//                    EditCountView(store: editStore)
//                        .toolbar(content: {
//                            ToolbarItem(placement: .cancellationAction) {
//                                Button("Cancel") { viewStore.send(.cancelEdit) }
//                            }
//                            ToolbarItem(placement: .primaryAction) {
//                                Button("Save") { viewStore.send(.saveEdit) }
//                            }
//                        })
//                }
//            }
        }
    }
}
