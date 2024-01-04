import SwiftUI
import ComposableArchitecture

struct EditOccurrenceView: View {
    let store: Store<EditOccurrenceReducer.State, EditOccurrenceReducer.Action>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Text("Date")
                    Spacer()
                    DatePicker("", selection: viewStore.binding(get: { _ in viewStore.occurrence.date ?? Date() }, send: { .setDate($0) }))
                }
                HStack {
                    Text("Types:")
                    Spacer()
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(viewStore.quantities) { quantity in
                                Button(action: {
                                    viewStore.send(.toggledQuantity(quantity))
                                }) {
                                    Text(quantity.symbol)
                                }
                                .padding(8)
                                .cornerRadius(8, antialiased: true)
                                .border(Color.primary, width: quantity.isSelected ? 4 : 1)
                            }
                        }
                    }
                    Spacer()
                }.padding()
                ForEachStore(store.scope(state: { state in
                    return state.quantities.filter(\.isSelected)
                }, action: EditOccurrenceReducer.Action.quantity(_:_:))) { quantityStore in
                    AddQuantityView(store: quantityStore).padding()
                }
                Spacer()
            }.onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct AddQuantityView: View {
    let store: Store<EditQuantityReducer.State, EditQuantityReducer.Action>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.units {
            case .time:
                TimerView(store: store.scope(state: { $0 }, action: { $0 }))
            case .size:
                Picker("How big was the \(viewStore.symbol)?", selection: viewStore.binding(get: { _ in viewStore.amount }, send: { .binding(.set(\.$amount, $0)) })) {
                    Text("Choose").tag(0)
                    Text("Tiny").tag(1)
                    Text("Small").tag(2)
                    Text("Medium").tag(3)
                    Text("Big").tag(4)
                    Text("Huge").tag(5)
                }
            case .mL:
                HStack {
                    Text("Amount: ")
                    Spacer()
                    TextField("mL", text: viewStore.binding(
                        get: { _ in viewStore.amount == -1 ? "" : "\(viewStore.amount)" },
                        send: { .binding(.set(\.$amount, Int((Double($0) ?? 0) * 100_000))) }))
                    .keyboardType(.decimalPad)
                }
            case .oz:
                HStack {
                    Text("Amount: ")
                    Spacer()
                    TextField("oz", text: viewStore.binding(
                        get: { _ in viewStore.amount == -1 ? "" : "\(viewStore.amount)" },
                        send: { .binding(.set(\.$amount, Int((Double($0) ?? 0) * 100))) }))
                    .keyboardType(.decimalPad)
                }
            default:
                Text("Unsupported")
            }
        }
    }
}

struct TimerView: View {
    let store: Store<EditQuantityReducer.State, EditQuantityReducer.Action>
    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @State var now = Date()
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Text("\(viewStore.symbol) start time:")
                    Spacer()
                    if let startTime = viewStore.startTime {
                        DatePicker("", selection: viewStore.binding(get: { _ in startTime }, send: { .binding(.set(\.$startTime, $0)) }))
                    } else {
                        Button(action: { viewStore.send(.binding(.set(\.$startTime, Date()))) }, label: {
                            Text("Set")
                        })
                    }
                }
                HStack {
                    Text("\(viewStore.symbol) end time:")
                    Spacer()
                    if let endTime = viewStore.endTime {
                        DatePicker("", selection: viewStore.binding(get: { _ in endTime }, send: { .binding(.set(\.$endTime, $0)) }))
                    } else {
                        Button(action: { viewStore.send(.binding(.set(\.$endTime, Date()))) }, label: {
                            Text("Set")
                        })
                    }
                }
                Button(action: {
                    if let startTime = viewStore.startTime, viewStore.endTime == nil {
                        viewStore.send(.binding(.set(\.$endTime, Date())))
                    } else {
                        viewStore.send(.binding(.set(\.$startTime, Date())))
                    }
                }) {
                    VStack {
                        if let start = viewStore.startTime {
                            if let end = viewStore.endTime {
                                Text("\(formatter.string(from: end.timeIntervalSince1970 - start.timeIntervalSince1970)!)").foregroundColor(.white)
                            } else {
                                Text("\(formatter.string(from: now.timeIntervalSince1970 - start.timeIntervalSince1970)!)").foregroundColor(.white)
                                    .onReceive(timer, perform: { _ in
                                        now = Date()
                                    })
                            }
                        }
                        if let startTime = viewStore.startTime, viewStore.endTime == nil {
                            Image(systemName: "square.fill").foregroundColor(Color.white)
                        } else {
                            Image(systemName: "play.fill").foregroundColor(Color.white)
                        }
                    }
                }
                .frame(width: 200, height: 200)
                .background(Color.accentColor)
                .clipShape(Circle())
                .padding()
            }
        }
    }
}

struct EditOccurrenceView_Previews: PreviewProvider {
    static var previews: some View {
        let quantitiesArray = [EditQuantityReducer.State(id: 1, symbol: "🍼", units: .oz),
                               EditQuantityReducer.State(id: 2, symbol: "💩", units: .size),
                               EditQuantityReducer.State(id: 3, symbol: "💤", units: .time),
                               EditQuantityReducer.State(id: 4, symbol: "💉", units: .mL)]
        let quantities = IdentifiedArray(uniqueElements: quantitiesArray)
        let count = Count(id: 1,
                          title: "Diaper",
                          interval: .day,
                          quantities: quantities,
                          occurrences: [],
                          history: [])
        let initialState = EditOccurrenceReducer.State(count: count,
                                                       occurrence: Occurrence(id: 1, date: Date(), quantities: []),
                                                       quantities: quantities)
        let store = Store(initialState: initialState,
                          reducer: { EditOccurrenceReducer() })
        EditOccurrenceView(store: store)
    }
}
