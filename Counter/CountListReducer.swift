import SwiftUI
import ComposableArchitecture
import Tagged

func fetchCountsDefaults() async -> [Count] {
    let data = UserDefaults.standard.data(forKey: "counts")//savedCounts.data(using: .utf8)//
    if var result = try? decoder.decode([Count].self, from: data ?? Data()) {
        var counts = [Count]()
        for n in 0..<result.count {
            var count = result[n]
            if var occurrences = count.occurrences {
                for i in 0..<occurrences.count {
                    occurrences[i].countId = count.id
                    if occurrences[i].id.rawValue < 100 {
                        occurrences[i].id = Occurrence.ID(Int.random(in: 0..<Int.max))
                    }
                    occurrences[i].countName = count.title
                }
                count.occurrences = occurrences
            }
            for i in 0..<(count.history ?? []).count {
                var oldCount = count.history![i]
                if var occurrences = oldCount.occurrences {
                    for i in 0..<occurrences.count {
                        if occurrences[i].id.rawValue < 100 {
                            occurrences[i].id = Occurrence.ID(Int.random(in: 0..<Int.max))
                        }
                        occurrences[i].countName = oldCount.title
                    }
                    oldCount.occurrences = occurrences
                }
                count.history?[i] = oldCount
            }
            if count.shouldAdvance() {
                let newCount = count.advancedOneInterval()
                counts.append(newCount)
            } else {
                counts.append(count)
            }
        }
        return counts
    }
    return []// [Count(id: 1, title: "Drinks", number: 11, interval: .week, quantities: nil, occurrences: nil), Count(id: 2, title: "Drinks", number: 11, interval: .week, quantities: nil, occurrences: nil)]
}

func saveCountsDefaults(_ counts: [Count]) async -> Void {
    UserDefaults.standard.set(try? encoder.encode(counts), forKey: "counts")
}

class CountListReducer: Reducer {
    var fetchCounts: () async -> [Count] = fetchCountsDefaults
    var saveCounts: ([Count]) async -> Void = saveCountsDefaults(_:)
    
    struct State: Equatable {
        var counts: IdentifiedArrayOf<Count> = IdentifiedArrayOf<Count>()
    }
    
    enum Action {
        case onAppear
        case countsLoaded(IdentifiedArrayOf<Count>)
        case count(Count.ID, CountReducer.Action)
        case saveCount(Count)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in await send(.countsLoaded(IdentifiedArray(uniqueElements: await self.fetchCounts()))) }
            case .countsLoaded(let counts):
                state.counts = counts
            case .saveCount(var count):
                if count.intervalStart == nil {
                    count.intervalStart = count.startOfThisInterval()
                }
                if let index = state.counts.index(id: count.id) {
                    state.counts.remove(id: count.id)
                    state.counts.insert(count, at: index)
                } else {
                    state.counts.append(count)
                }
                
                let currentCounts = state.counts
                return .run { [self] send in
                    await saveCounts(currentCounts.elements)
                    await send(.countsLoaded(IdentifiedArray(uniqueElements: await self.fetchCounts())))
                }
            case .count(_, _): break
            }
            return .none
        }.forEach(\.counts, action: /Action.count(_:_:)) {
            CountReducer()
        }
    }
}

let savedCounts = """
[{
    "title": "Spoon potty",
    "occurrences": [],
    "id": 0,
    "history": [{
        "interval": "day",
        "title": "Spoon potty",
        "intervalStart": "2023-06-26T04:00:00Z",
        "occurrences": [{
            "id": 0,
            "date": "2023-06-26T21:46:11Z"
        }],
        "id": 0,
        "quantities": [{
            "units": "none",
            "symbol": "💩",
            "id": 0,
            "asdfasdf": "hi",
            "amount": -1,
            "startTime": "2023-06-26T21:46:11Z",
            "endTime": "2023-06-26T21:46:11Z",
            "isSelected": false
        }, {
            "symbol": "💦",
            "amount": -1,
            "units": "none",
            "isSelected": false,
            "id": 1
        }]
    }, {
        "title": "Spoon potty",
        "id": 0,
        "occurrences": [],
        "interval": "day",
        "intervalStart": "2023-06-28T04:00:00Z",
        "quantities": [{
            "symbol": "💩",
            "id": 0,
            "amount": -1,
            "units": "none",
            "isSelected": false
        }, {
            "amount": -1,
            "id": 1,
            "units": "none",
            "isSelected": false,
            "symbol": "💦"
        }]
    }, {
        "id": 0,
        "intervalStart": "2023-06-29T04:00:00Z",
        "title": "Spoon potty",
        "interval": "day",
        "quantities": [{
            "isSelected": false,
            "id": 0,
            "amount": -1,
            "units": "none",
            "symbol": "💩"
        }, {
            "amount": -1,
            "id": 1,
            "units": "none",
            "isSelected": false,
            "symbol": "💦"
        }],
        "occurrences": []
    }, {
        "title": "Spoon potty",
        "occurrences": [],
        "interval": "day",
        "id": 0,
        "intervalStart": "2023-06-30T04:00:00Z",
        "quantities": [{
            "symbol": "💩",
            "isSelected": false,
            "id": 0,
            "amount": -1,
            "units": "none"
        }, {
            "id": 1,
            "symbol": "💦",
            "isSelected": false,
            "amount": -1,
            "units": "none"
        }]
    }, {
        "occurrences": [],
        "id": 0,
        "interval": "day",
        "quantities": [{
            "amount": -1,
            "id": 0,
            "symbol": "💩",
            "units": "none",
            "isSelected": false
        }, {
            "amount": -1,
            "symbol": "💦",
            "id": 1,
            "isSelected": false,
            "units": "none"
        }],
        "intervalStart": "2023-07-01T04:00:00Z",
        "title": "Spoon potty"
    }, {
        "id": 0,
        "interval": "day",
        "intervalStart": "2023-07-02T04:00:00Z",
        "occurrences": [],
        "title": "Spoon potty",
        "quantities": [{
            "id": 0,
            "amount": -1,
            "symbol": "💩",
            "units": "none",
            "isSelected": false
        }, {
            "amount": -1,
            "id": 1,
            "symbol": "💦",
            "units": "none",
            "isSelected": false
        }]
    }],
    "interval": "day",
    "intervalStart": "2023-10-22T04:00:00Z",
    "quantities": [{
        "id": 0,
        "isSelected": false,
        "units": "none",
        "amount": -1,
        "symbol": "💩"
    }, {
        "symbol": "💦",
        "isSelected": false,
        "units": "none",
        "id": 1,
        "amount": -1
    }]
}, {
    "occurrences": [],
    "title": "Cam diaper",
    "id": 1,
    "intervalStart": "2023-10-22T04:00:00Z",
    "history": [{
        "title": "Cam diaper",
        "quantities": [{
            "id": 0,
            "units": "size",
            "amount": -1,
            "symbol": "💩",
            "isSelected": false
        }, {
            "units": "size",
            "isSelected": false,
            "amount": -1,
            "id": 1,
            "symbol": "💦"
        }],
        "id": 1,
        "occurrences": [{
            "date": "2023-06-26T21:57:27Z",
            "id": 0
        }],
        "interval": "day",
        "intervalStart": "2023-06-26T04:00:00Z"
    }, {
        "title": "Cam diaper",
        "quantities": [{
            "units": "size",
            "id": 0,
            "amount": -1,
            "symbol": "💩",
            "isSelected": false
        }, {
            "id": 1,
            "symbol": "💦",
            "units": "size",
            "amount": -1,
            "isSelected": false
        }],
        "interval": "day",
        "id": 1,
        "intervalStart": "2023-06-28T04:00:00Z",
        "occurrences": []
    }, {
        "quantities": [{
            "isSelected": false,
            "symbol": "💩",
            "units": "size",
            "amount": -1,
            "id": 0
        }, {
            "isSelected": false,
            "id": 1,
            "amount": -1,
            "symbol": "💦",
            "units": "size"
        }],
        "interval": "day",
        "occurrences": [],
        "id": 1,
        "title": "Cam diaper",
        "intervalStart": "2023-06-29T04:00:00Z"
    }, {
        "title": "Cam diaper",
        "quantities": [{
            "units": "size",
            "id": 0,
            "amount": -1,
            "isSelected": false,
            "symbol": "💩"
        }, {
            "isSelected": false,
            "id": 1,
            "units": "size",
            "symbol": "💦",
            "amount": -1
        }],
        "interval": "day",
        "occurrences": [],
        "id": 1,
        "intervalStart": "2023-06-30T04:00:00Z"
    }, {
        "interval": "day",
        "intervalStart": "2023-07-01T04:00:00Z",
        "quantities": [{
            "units": "size",
            "isSelected": false,
            "amount": -1,
            "id": 0,
            "symbol": "💩"
        }, {
            "symbol": "💦",
            "amount": -1,
            "id": 1,
            "isSelected": false,
            "units": "size"
        }],
        "occurrences": [],
        "id": 1,
        "title": "Cam diaper"
    }, {
        "title": "Cam diaper",
        "id": 1,
        "occurrences": [],
        "interval": "day",
        "quantities": [{
            "amount": -1,
            "isSelected": false,
            "id": 0,
            "units": "size",
            "symbol": "💩"
        }, {
            "id": 1,
            "amount": -1,
            "units": "size",
            "isSelected": false,
            "symbol": "💦"
        }],
        "intervalStart": "2023-07-02T04:00:00Z"
    }],
    "interval": "day",
    "quantities": [{
        "isSelected": false,
        "units": "size",
        "id": 0,
        "amount": -1,
        "symbol": "💩"
    }, {
        "amount": -1,
        "units": "size",
        "symbol": "💦",
        "isSelected": false,
        "id": 1
    }]
}, {
    "history": [{
        "title": "Drinks",
        "intervalStart": "2023-06-26T04:00:00Z",
        "quantities": [],
        "id": 2,
        "occurrences": [{
            "id": 0,
            "date": "2023-06-26T21:23:57Z"
        }, {
            "date": "2023-06-26T21:45:59Z",
            "id": 1
        }, {
            "id": 2,
            "date": "2023-06-28T23:29:52Z"
        }, {
            "id": 3,
            "date": "2023-06-28T23:29:52Z"
        }, {
            "date": "2023-06-29T01:28:07Z",
            "id": 4
        }, {
            "date": "2023-06-29T19:04:27Z",
            "id": 5
        }, {
            "id": 6,
            "date": "2023-06-29T22:33:44Z"
        }, {
            "id": 7,
            "date": "2023-06-29T23:18:35Z"
        }, {
            "date": "2023-06-30T21:45:52Z",
            "id": 8
        }, {
            "id": 9,
            "date": "2023-06-30T22:39:53Z"
        }, {
            "id": 10,
            "date": "2023-07-02T00:21:10Z"
        }, {
            "date": "2023-07-02T00:21:11Z",
            "id": 11
        }, {
            "id": 12,
            "date": "2023-07-02T22:45:32Z"
        }, {
            "date": "2023-07-02T22:45:33Z",
            "id": 13
        }, {
            "id": 14,
            "date": "2023-07-03T03:53:33Z"
        }],
        "interval": "week"
    }, {
        "intervalStart": "2023-07-03T04:00:00Z",
        "interval": "week",
        "title": "Drinks",
        "id": 2,
        "quantities": [],
        "occurrences": [{
            "id": 0,
            "date": "2023-07-04T19:00:36Z"
        }, {
            "date": "2023-07-04T23:25:29Z",
            "id": 1
        }, {
            "date": "2023-07-04T23:25:30Z",
            "id": 2
        }, {
            "date": "2023-07-06T23:06:15Z",
            "id": 3
        }, {
            "id": 4,
            "date": "2023-07-08T14:49:12Z"
        }, {
            "id": 5,
            "date": "2023-07-08T14:49:15Z"
        }, {
            "date": "2023-07-08T14:49:19Z",
            "id": 6
        }, {
            "id": 7,
            "date": "2023-07-08T20:23:49Z"
        }, {
            "id": 8,
            "date": "2023-07-09T04:19:59Z"
        }, {
            "id": 9,
            "date": "2023-07-10T02:00:52Z"
        }]
    }, {
        "occurrences": [{
            "date": "2023-07-11T00:05:49Z",
            "id": 0
        }, {
            "id": 1,
            "date": "2023-07-11T03:15:34Z"
        }, {
            "id": 2,
            "date": "2023-07-11T19:50:02Z"
        }, {
            "date": "2023-07-12T02:25:34Z",
            "id": 3
        }, {
            "id": 4,
            "date": "2023-07-14T18:55:23Z"
        }, {
            "date": "2023-07-14T18:55:24Z",
            "id": 5
        }, {
            "id": 6,
            "date": "2023-07-14T18:55:24Z"
        }, {
            "date": "2023-07-15T00:15:46Z",
            "id": 7
        }, {
            "id": 8,
            "date": "2023-07-15T00:15:47Z"
        }, {
            "date": "2023-07-16T15:18:44Z",
            "id": 9
        }, {
            "date": "2023-07-16T22:51:38Z",
            "id": 10
        }, {
            "date": "2023-07-16T22:51:38Z",
            "id": 11
        }, {
            "id": 12,
            "date": "2023-07-16T22:51:39Z"
        }],
        "interval": "week",
        "title": "Drinks",
        "intervalStart": "2023-07-10T04:00:00Z",
        "id": 2,
        "quantities": []
    }, {
        "intervalStart": "2023-07-17T04:00:00Z",
        "occurrences": [{
            "id": 0,
            "date": "2023-07-18T13:05:47Z"
        }, {
            "id": 1,
            "date": "2023-07-19T00:03:22Z"
        }, {
            "date": "2023-07-19T00:03:23Z",
            "id": 2
        }, {
            "id": 3,
            "date": "2023-07-22T13:08:38Z"
        }, {
            "id": 4,
            "date": "2023-07-22T13:08:39Z"
        }, {
            "id": 5,
            "date": "2023-07-22T13:08:40Z"
        }, {
            "id": 6,
            "date": "2023-07-23T00:33:40Z"
        }, {
            "date": "2023-07-23T00:55:47Z",
            "id": 7
        }],
        "title": "Drinks",
        "interval": "week",
        "id": 2,
        "quantities": []
    }, {
        "interval": "week",
        "quantities": [],
        "id": 2,
        "intervalStart": "2023-07-24T04:00:00Z",
        "occurrences": [{
            "id": 0,
            "date": "2023-07-24T10:54:36Z"
        }, {
            "id": 1,
            "date": "2023-07-24T22:24:39Z"
        }, {
            "date": "2023-07-24T22:24:39Z",
            "id": 2
        }, {
            "id": 3,
            "date": "2023-07-25T21:31:11Z"
        }, {
            "date": "2023-07-26T01:31:57Z",
            "id": 4
        }, {
            "id": 5,
            "date": "2023-07-26T01:31:57Z"
        }, {
            "date": "2023-07-27T17:41:19Z",
            "id": 6
        }, {
            "id": 7,
            "date": "2023-07-27T21:18:26Z"
        }, {
            "date": "2023-07-27T23:43:56Z",
            "id": 8
        }, {
            "date": "2023-07-28T22:27:15Z",
            "id": 9
        }, {
            "id": 10,
            "date": "2023-07-30T03:05:47Z"
        }, {
            "date": "2023-07-30T03:05:48Z",
            "id": 11
        }, {
            "date": "2023-07-30T03:05:49Z",
            "id": 12
        }, {
            "date": "2023-07-30T22:03:26Z",
            "id": 13
        }],
        "title": "Drinks"
    }, {
        "interval": "week",
        "quantities": [],
        "title": "Drinks",
        "intervalStart": "2023-07-31T04:00:00Z",
        "occurrences": [{
            "id": 0,
            "date": "2023-08-03T00:22:32Z"
        }, {
            "id": 1,
            "date": "2023-08-03T00:22:33Z"
        }, {
            "date": "2023-08-04T00:49:43Z",
            "id": 2
        }, {
            "id": 3,
            "date": "2023-08-04T00:49:43Z"
        }, {
            "date": "2023-08-05T14:55:23Z",
            "id": 4
        }, {
            "date": "2023-08-05T14:55:24Z",
            "id": 5
        }, {
            "id": 6,
            "date": "2023-08-05T14:55:24Z"
        }, {
            "date": "2023-08-06T13:51:35Z",
            "id": 7
        }],
        "id": 2
    }, {
        "interval": "week",
        "quantities": [],
        "occurrences": [{
            "date": "2023-08-08T00:14:04Z",
            "id": 0
        }, {
            "date": "2023-08-08T00:14:05Z",
            "id": 1
        }, {
            "date": "2023-08-08T00:14:06Z",
            "id": 2
        }, {
            "date": "2023-08-09T01:36:31Z",
            "id": 3
        }, {
            "date": "2023-08-10T00:10:37Z",
            "id": 4
        }, {
            "id": 5,
            "date": "2023-08-10T18:46:23Z"
        }, {
            "date": "2023-08-10T20:39:55Z",
            "id": 6
        }, {
            "id": 7,
            "date": "2023-08-12T21:08:31Z"
        }, {
            "id": 8,
            "date": "2023-08-12T21:08:34Z"
        }, {
            "date": "2023-08-13T20:33:48Z",
            "id": 9
        }],
        "id": 2,
        "intervalStart": "2023-08-07T04:00:00Z",
        "title": "Drinks"
    }, {
        "title": "Drinks",
        "intervalStart": "2023-08-14T04:00:00Z",
        "id": 2,
        "interval": "week",
        "quantities": [],
        "occurrences": [{
            "id": 0,
            "date": "2023-08-15T22:25:18Z"
        }, {
            "date": "2023-08-15T22:25:19Z",
            "id": 1
        }, {
            "id": 2,
            "date": "2023-08-17T14:38:39Z"
        }, {
            "id": 3,
            "date": "2023-08-17T14:38:40Z"
        }, {
            "date": "2023-08-17T14:38:40Z",
            "id": 4
        }, {
            "id": 5,
            "date": "2023-08-17T14:38:41Z"
        }, {
            "id": 6,
            "date": "2023-08-19T17:20:20Z"
        }, {
            "id": 7,
            "date": "2023-08-19T17:20:20Z"
        }, {
            "id": 8,
            "date": "2023-08-19T23:50:56Z"
        }, {
            "date": "2023-08-20T00:09:20Z",
            "id": 9
        }]
    }, {
        "id": 2,
        "interval": "week",
        "occurrences": [{
            "date": "2023-08-22T01:48:08Z",
            "id": 0
        }, {
            "date": "2023-08-22T01:48:09Z",
            "id": 1
        }, {
            "id": 2,
            "date": "2023-08-22T01:48:10Z"
        }, {
            "date": "2023-08-22T01:48:11Z",
            "id": 3
        }, {
            "id": 4,
            "date": "2023-08-23T21:33:49Z"
        }, {
            "date": "2023-08-23T21:33:50Z",
            "id": 5
        }, {
            "date": "2023-08-23T21:33:50Z",
            "id": 6
        }, {
            "date": "2023-08-23T21:33:51Z",
            "id": 7
        }, {
            "id": 8,
            "date": "2023-08-23T22:05:27Z"
        }, {
            "id": 9,
            "date": "2023-08-23T22:41:00Z"
        }, {
            "id": 10,
            "date": "2023-08-25T22:52:11Z"
        }, {
            "date": "2023-08-25T22:52:11Z",
            "id": 11
        }, {
            "date": "2023-08-26T20:27:17Z",
            "id": 12
        }, {
            "date": "2023-08-27T00:25:42Z",
            "id": 13
        }, {
            "date": "2023-08-27T00:25:46Z",
            "id": 14
        }, {
            "id": 15,
            "date": "2023-08-27T21:05:24Z"
        }, {
            "date": "2023-08-27T21:05:24Z",
            "id": 16
        }],
        "title": "Drinks",
        "intervalStart": "2023-08-21T04:00:00Z",
        "quantities": []
    }, {
        "intervalStart": "2023-08-28T04:00:00Z",
        "interval": "week",
        "quantities": [],
        "occurrences": [{
            "id": 0,
            "date": "2023-08-28T21:11:58Z"
        }, {
            "date": "2023-08-30T00:38:47Z",
            "id": 1
        }, {
            "date": "2023-08-30T00:38:47Z",
            "id": 2
        }, {
            "id": 3,
            "date": "2023-08-30T00:38:47Z"
        }, {
            "date": "2023-08-30T00:38:48Z",
            "id": 4
        }, {
            "id": 5,
            "date": "2023-08-31T04:29:03Z"
        }, {
            "date": "2023-08-31T20:30:30Z",
            "id": 6
        }, {
            "date": "2023-08-31T23:31:06Z",
            "id": 7
        }, {
            "id": 8,
            "date": "2023-09-02T01:38:51Z"
        }, {
            "id": 9,
            "date": "2023-09-02T04:04:21Z"
        }, {
            "date": "2023-09-02T22:05:59Z",
            "id": 10
        }, {
            "date": "2023-09-03T18:34:58Z",
            "id": 11
        }, {
            "date": "2023-09-03T19:41:03Z",
            "id": 12
        }],
        "title": "Drinks",
        "id": 2
    }, {
        "title": "Drinks",
        "interval": "week",
        "intervalStart": "2023-09-04T04:00:00Z",
        "quantities": [],
        "occurrences": [{
            "date": "2023-09-05T19:15:42Z",
            "id": 0
        }, {
            "date": "2023-09-05T19:15:42Z",
            "id": 1
        }, {
            "date": "2023-09-07T23:37:57Z",
            "id": 2
        }, {
            "date": "2023-09-08T19:03:47Z",
            "id": 3
        }, {
            "id": 4,
            "date": "2023-09-08T19:03:47Z"
        }, {
            "id": 5,
            "date": "2023-09-08T22:49:53Z"
        }, {
            "id": 6,
            "date": "2023-09-09T02:06:58Z"
        }, {
            "id": 7,
            "date": "2023-09-09T22:43:29Z"
        }],
        "id": 2
    }, {
        "intervalStart": "2023-09-11T04:00:00Z",
        "occurrences": [{
            "date": "2023-09-14T12:14:14Z",
            "id": 0
        }, {
            "date": "2023-09-14T12:14:15Z",
            "id": 1
        }, {
            "date": "2023-09-14T12:14:51Z",
            "id": 2
        }, {
            "date": "2023-09-14T12:14:52Z",
            "id": 3
        }, {
            "id": 4,
            "date": "2023-09-14T12:14:52Z"
        }, {
            "date": "2023-09-15T12:10:53Z",
            "id": 5
        }, {
            "id": 6,
            "date": "2023-09-15T12:10:56Z"
        }, {
            "id": 7,
            "date": "2023-09-16T04:26:26Z"
        }, {
            "id": 8,
            "date": "2023-09-16T04:26:30Z"
        }, {
            "id": 9,
            "date": "2023-09-16T23:56:56Z"
        }],
        "interval": "week",
        "quantities": [],
        "id": 2,
        "title": "Drinks"
    }, {
        "id": 2,
        "interval": "week",
        "title": "Drinks",
        "intervalStart": "2023-09-18T04:00:00Z",
        "occurrences": [{
            "id": 0,
            "date": "2023-09-19T02:42:19Z"
        }, {
            "id": 1,
            "date": "2023-09-19T02:42:20Z"
        }, {
            "id": 2,
            "date": "2023-09-19T02:42:31Z"
        }, {
            "date": "2023-09-20T03:02:05Z",
            "id": 3
        }, {
            "id": 4,
            "date": "2023-09-20T03:02:05Z"
        }, {
            "id": 5,
            "date": "2023-09-20T23:42:33Z"
        }, {
            "date": "2023-09-21T00:33:54Z",
            "id": 6
        }, {
            "id": 7,
            "date": "2023-09-22T03:07:30Z"
        }, {
            "date": "2023-09-22T17:43:11Z",
            "id": 8
        }, {
            "date": "2023-09-22T19:46:32Z",
            "id": 9
        }, {
            "id": 10,
            "date": "2023-09-22T20:08:43Z"
        }, {
            "date": "2023-09-22T23:22:15Z",
            "id": 11
        }, {
            "id": 12,
            "date": "2023-09-23T19:28:44Z"
        }, {
            "id": 13,
            "date": "2023-09-23T20:20:52Z"
        }, {
            "id": 14,
            "date": "2023-09-25T00:26:02Z"
        }],
        "quantities": []
    }, {
        "title": "Drinks",
        "quantities": [],
        "interval": "week",
        "intervalStart": "2023-09-25T04:00:00Z",
        "occurrences": [{
            "id": 0,
            "date": "2023-09-25T23:31:07Z"
        }, {
            "id": 1,
            "date": "2023-09-26T03:38:34Z"
        }, {
            "date": "2023-09-26T23:29:09Z",
            "id": 2
        }, {
            "date": "2023-09-27T02:57:53Z",
            "id": 3
        }, {
            "id": 4,
            "date": "2023-09-27T21:56:59Z"
        }, {
            "id": 5,
            "date": "2023-09-29T00:57:06Z"
        }, {
            "id": 6,
            "date": "2023-09-29T00:57:06Z"
        }, {
            "id": 7,
            "date": "2023-09-30T05:13:51Z"
        }, {
            "id": 8,
            "date": "2023-09-30T05:13:51Z"
        }, {
            "id": 9,
            "date": "2023-09-30T05:13:52Z"
        }, {
            "date": "2023-10-01T02:16:02Z",
            "id": 10
        }, {
            "date": "2023-10-01T02:16:02Z",
            "id": 11
        }, {
            "id": 12,
            "date": "2023-10-02T00:33:16Z"
        }, {
            "id": 13,
            "date": "2023-10-02T00:33:16Z"
        }],
        "id": 2
    }, {
        "occurrences": [{
            "id": 0,
            "date": "2023-10-03T21:38:27Z"
        }, {
            "id": 1,
            "date": "2023-10-04T02:07:37Z"
        }, {
            "id": 2,
            "date": "2023-10-04T02:07:37Z"
        }, {
            "id": 3,
            "date": "2023-10-06T22:48:33Z"
        }, {
            "date": "2023-10-08T02:33:13Z",
            "id": 4
        }, {
            "id": 5,
            "date": "2023-10-09T00:23:38Z"
        }, {
            "id": 6,
            "date": "2023-10-09T00:23:38Z"
        }],
        "intervalStart": "2023-10-02T04:00:00Z",
        "quantities": [],
        "interval": "week",
        "title": "Drinks",
        "id": 2
    }, {
        "interval": "week",
        "quantities": [],
        "occurrences": [{
            "date": "2023-10-10T00:33:09Z",
            "id": 0
        }, {
            "id": 1,
            "date": "2023-10-10T00:33:09Z"
        }, {
            "id": 2,
            "date": "2023-10-10T00:33:09Z"
        }, {
            "date": "2023-10-11T02:48:42Z",
            "id": 3
        }, {
            "id": 4,
            "date": "2023-10-12T02:17:52Z"
        }, {
            "id": 5,
            "date": "2023-10-12T02:17:52Z"
        }, {
            "date": "2023-10-12T02:17:52Z",
            "id": 6
        }, {
            "date": "2023-10-13T02:16:36Z",
            "id": 7
        }, {
            "id": 8,
            "date": "2023-10-13T02:16:37Z"
        }, {
            "date": "2023-10-14T22:48:45Z",
            "id": 9
        }, {
            "date": "2023-10-15T03:22:18Z",
            "id": 10
        }, {
            "date": "2023-10-16T01:02:13Z",
            "id": 11
        }, {
            "id": 12,
            "date": "2023-10-16T01:02:14Z"
        }],
        "title": "Drinks",
        "id": 2,
        "intervalStart": "2023-10-09T04:00:00Z"
    }],
    "interval": "week",
    "id": 2,
    "title": "Drinks",
    "intervalStart": "2023-10-16T04:00:00Z",
    "quantities": [],
    "occurrences": [{
        "id": 0,
        "date": "2023-10-18T01:39:58Z"
    }, {
        "id": 1,
        "date": "2023-10-19T01:58:03Z"
    }, {
        "id": 2,
        "date": "2023-10-20T11:43:14Z"
    }, {
        "date": "2023-10-20T11:43:14Z",
        "id": 3
    }, {
        "date": "2023-10-20T11:43:14Z",
        "id": 4
    }, {
        "id": 5,
        "date": "2023-10-20T22:15:07Z"
    }, {
        "id": 6,
        "date": "2023-10-21T21:32:10Z"
    }, {
        "date": "2023-10-21T21:32:10Z",
        "id": 7
    }, {
        "id": 8,
        "date": "2023-10-22T03:40:29Z"
    }, {
        "date": "2023-10-22T19:42:50Z",
        "id": 9
    }]
}, {
    "occurrences": [],
    "title": "Cameron Bath",
    "quantities": [],
    "history": [{
        "occurrences": [{
            "id": 0,
            "date": "2023-07-04T18:15:21Z"
        }],
        "title": "Cameron Bath",
        "quantities": [],
        "interval": "week",
        "id": 3,
        "intervalStart": "2023-07-03T04:00:00Z"
    }],
    "id": 3,
    "interval": "week",
    "intervalStart": "2023-10-16T04:00:00Z"
}, {
    "title": "Cam bottle",
    "interval": "day",
    "intervalStart": "2023-10-22T04:00:00Z",
    "history": [],
    "id": 4,
    "occurrences": [],
    "quantities": [{
        "units": "mL",
        "amount": -1,
        "symbol": "🍼",
        "isSelected": false,
        "id": 0
    }]
}, {
    "occurrences": [],
    "quantities": [{
        "amount": -1,
        "symbol": "⬅️⏱️",
        "isSelected": false,
        "units": "time",
        "id": 0
    }, {
        "symbol": "➡️⏱️",
        "isSelected": false,
        "amount": -1,
        "id": 1,
        "units": "time"
    }],
    "history": [],
    "title": "Cam stillen",
    "intervalStart": "2023-10-22T04:00:00Z",
    "id": 5,
    "interval": "day"
}, {
    "occurrences": [{
        "date": "2023-10-17T16:49:27Z",
        "id": 0
    }],
    "title": "Spoon regular meds",
    "interval": "year",
    "id": 6,
    "intervalStart": "2023-01-01T05:00:00Z",
    "quantities": []
}]
"""
