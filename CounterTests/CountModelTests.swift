//
//  CountModelTests.swift
//  CounterTests
//
//  Created by Elliot Schrock on 6/25/23.
//

import XCTest
@testable import Counter

final class CountModelTests: XCTestCase {
    
    func testShouldAdvance() throws {
        let count = Count(id: 1, title: "", interval: .day, intervalStart: Date(timeIntervalSinceNow: -2 * 24 * 60 * 60), quantities: [], occurrences: nil, history: [])
        
        XCTAssert(count.shouldAdvance())
    }
    
    func testShouldNotAdvance() throws {
        let count = Count(id: 1, title: "", interval: .day, intervalStart: Date(timeIntervalSinceNow: -2 * 60 * 60), quantities: [], occurrences: nil, history: [])
        
        XCTAssertFalse(count.shouldAdvance())
    }
    
    func testAdvance() throws {
        let count = Count(id: 1, title: "", interval: .day, intervalStart: Date(timeIntervalSinceNow: -2 * 24 * 60 * 60), quantities: [], occurrences: nil, history: [])
        
        let newCount = count.advancedOneInterval()
        
        XCTAssertNotNil(newCount.history)
        XCTAssertEqual(newCount.history?.count, 1)
    }

}
