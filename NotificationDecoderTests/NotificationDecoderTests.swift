//
//  NotificationDecoderTests.swift
//  NotificationDecoderTests
//
//  Created by Tim Ekl on 2018.02.17.
//  Copyright © 2018 Tim Ekl. All rights reserved.
//

import XCTest

class NotificationDecoderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testObjectRawPointerParsing_8char() {
        let deadbeef = Observation.Object(pointerString: "0xdeadbeef", replacements: [])
        XCTAssertEqual(deadbeef!, Observation.Object.raw(0xdeadbeef))
    }
    
    func testObjectRawPointerParsing_16char() {
        let doubleBeef = Observation.Object(pointerString: "0xdeadbeefdeadbeef", replacements: [])
        XCTAssertEqual(doubleBeef!, Observation.Object.raw(0xdeadbeefdeadbeef))
    }
    
    func testObjectReplacementMatching_8char() {
        let replacement = Replacement(pointer: 0xdeadbeef, text: "Dead Beef")
        let deadbeef = Observation.Object(pointerString: "0xdeadbeef", replacements: [replacement])
        XCTAssertEqual(deadbeef!, Observation.Object.named(replacement))
    }
    
    func testObjectReplacementMatching_16char() {
        let replacement = Replacement(pointer: 0xdeadbeefdeadbeef, text: "Double Beef")
        let doubleBeef = Observation.Object(pointerString: "0xdeadbeefdeadbeef", replacements: [replacement])
        XCTAssertEqual(doubleBeef!, Observation.Object.named(replacement))
    }
    
    func testSuccessfulObservationLineParse() {
        let line = "com.example.notification, 0x1234, 0x5678, 1001"
        let replacements: [Replacement] = [
            Replacement(pointer: 0x1234, text: "foo"),
            Replacement(pointer: 0x5678, text: "bar"),
        ]
        
        guard let observation = Observation(line: line, replacements: replacements) else {
            XCTFail("Expected to parse this observation")
            return
        }
        
        XCTAssertEqual(observation.name, "com.example.notification")
        XCTAssertEqual(observation.object, .named(replacements[0]))
        XCTAssertEqual(observation.observer, .named(replacements[1]))
        XCTAssertEqual(observation.options, 1001)
        XCTAssertTrue(observation.hasReplacementMatch)
    }
    
}
