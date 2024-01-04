//
//  EditQuantityTests.swift
//  CounterTests
//
//  Created by Elliot Schrock on 10/22/23.
//

import XCTest
@testable import Counter
import ComposableArchitecture

@MainActor
final class EditQuantityTests: XCTestCase {
    func testBindStartTime() async throws {
        let state = EditQuantityReducer.State(id: 1)
        let store = TestStore(initialState: state, reducer: { EditQuantityReducer() })
        
        let date = Date()
        await store.send(.binding(.set(\.$startTime, date))) {
            $0.startTime = date
        }
    }

}
