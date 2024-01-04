import SwiftUI
import ComposableArchitecture

struct CounterView: View {
    @Environment(\.scenePhase) var scenePhase
    let store: StoreOf<CounterReducer>
    
    struct ViewState: Equatable {
        let countId: Count.ID?
        let occurrenceId: Occurrence.ID?
        let counts: IdentifiedArrayOf<Count>
        
        init(state: CounterReducer.State) {
            countId = state.editCount?.count.id
            occurrenceId = state.editOccurrence?.occurrence.id
            self.counts = state.list.counts
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { (viewStore: ViewStore<ViewState, CounterReducer.Action>) in
            NavigationStack { 
                GeometryReader { geometry in
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count:  Int(geometry.size.width / 355)), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEachStore(self.store.scope(state: \.list.counts, action: CounterReducer.Action.count(_:_:))) { countStore in
                                CountCardView(store: countStore)
                            }
                        }
                    }
                }.onAppear(perform: {
                    viewStore.send(CounterReducer.Action.list(.onAppear))
                })
                    .navigationTitle("Counts")
                    .toolbar(content: {
                        HStack {
                            Button(action: { viewStore.send(CounterReducer.Action.occurrencesTapped) }, label: {
                                Image(systemName: "list.number")
                            })
                            Spacer()
                            Button(action: { viewStore.send(CounterReducer.Action.addNewTapped) }, label: {
                                Image(systemName: "plus")
                            })
                        }
                    })
            }
            .sheet(store: store.scope(state: \.$editOccurrence, action: { CounterReducer.Action.editOccurrence($0) })) { editStore in
                NavigationStack {
                    EditOccurrenceView(store: editStore)
                        .toolbar(content: {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { viewStore.send(.cancelOccurrence) }
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button("Save") { viewStore.send(.saveOccurrence) }
                            }
                        })
                        .navigationTitle("New Occurrence")
                }
            }
            .sheet(store: store.scope(state: \.$newCount, action: { CounterReducer.Action.edit($0) })) { editStore in
                NavigationStack {
                    EditCountView(store: editStore)
                        .toolbar(content: {
                            ToolbarItem(placement: .primaryAction) {
                                Button("Save") { viewStore.send(.saveEdit) }
                            }
                        })
                        .navigationTitle("New Count")
                }
            }
            .sheet(store: store.scope(state: \.$editCount, action: { CounterReducer.Action.edit($0) })) { editStore in
                NavigationStack {
                    EditCountView(store: editStore)
                        .toolbar(content: {
                            ToolbarItem(placement: .primaryAction) {
                                Button("Save") { viewStore.send(.saveEdit) }
                            }
                        })
                        .navigationTitle("Edit Count")
                }
            }
            .sheet(store: store.scope(state: \.$chart, action: { CounterReducer.Action.chart($0) })) { chartStore in
                NavigationStack {
                    ChartView(store: chartStore)
                }
            }
            .sheet(store: store.scope(state: \.$occurrenceList, action: { CounterReducer.Action.occurrenceList($0) })) { occListStore in
                NavigationStack {
                    OccurrenceListView(store: occListStore)
                }
            }
            .onChange(of: scenePhase) { newValue in
                viewStore.send(.didChangeScenePhase)
            }
        }
    }
}
