//
//  OccurrenceListView.swift
//  Counter
//
//  Created by Elliot Schrock on 11/16/23.
//

import SwiftUI
import ComposableArchitecture

struct OccurrenceListView: View {
    let store: StoreOf<OccurrenceListReducer>
    var formatter: DateFormatter {
        let _formatter = DateFormatter()
        _formatter.dateStyle = .short
        _formatter.timeStyle = .short
        return _formatter
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List(viewStore.occurrences) { occurrence in
                    VStack {
                        HStack {
                            Text("+1 \(occurrence.countName ?? "")")
                            Spacer()
                            Text("\(formatter.string(from: occurrence.date ?? Date()))")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            VStack {
                                ForEach(occurrence.quantities ?? []) { quantity in
                                    Text("\(quantity.symbol): \(quantity.amountDescription)")
                                }
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "arrow.right")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }.navigationTitle("Occurrences")
            .onAppear {
//                viewStore.send(.onAppear)
            }
        }
    }
}

