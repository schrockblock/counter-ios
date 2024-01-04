import SwiftUI
import ComposableArchitecture

let buttonSize: CGFloat = 56

struct CountCardView: View {
    let store: Store<CountReducer.State, CountReducer.Action> 
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in 
            VStack {
                HStack {
                    VStack {
                        HStack {
                            Button(action: { viewStore.send(.editTapped) }) {
                                Text(viewStore.title.isEmpty ? "[No Title]" : viewStore.title).font(.title)
                            }
                            Spacer()
                            Button(action: { viewStore.send(.chartTapped) }) {
                                Text("\(viewStore.occurrences?.count ?? 0)").font(.largeTitle)
                            }
                        }
                        .padding(4)
                        HStack {
                            if let avg = viewStore.avg {
                                Text("Avg/\(viewStore.interval?.rawValue ?? ""): \(avg)")
                            }
                            Spacer()
                            if let timeString = viewStore.occurrences?.last?.date?.ago {
                                Text("Last: \(timeString)")
                            }
                        }
                        .padding(4)
                    }
                    VStack {
                        Button(action: { viewStore.send(.increment) }, label: {
                            Image(systemName: "plus")
                                .padding(4)
                                .background(Color.white)
                                .cornerRadius(buttonSize / 2, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                                .frame(width: buttonSize, height: buttonSize, alignment: .center)
                        })
                        if viewStore.quantities.isEmpty {
                            Button(action: { viewStore.send(.decrement) }, label: {
                                Image(systemName: "minus")
                                    .padding(4)
                                    .background(Color.white)
                                    .cornerRadius(buttonSize / 2, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                                    .frame(width: buttonSize, height: buttonSize, alignment: .center)
                            })
                        }
                    }
                    .background(Color(.sRGB, red: 0.9, green: 0.9, blue: 0.9, opacity: 1))
                    .cornerRadius((buttonSize + 8) / 2, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                }
                .padding(8)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .padding(8)
                .shadow(color: .gray, radius: 4, x: 4, y: 4)
            }
        }
    }
}
