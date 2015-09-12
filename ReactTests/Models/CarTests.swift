//
//  CarTests.swift
//  React
//
//  Created by Wes Billman on 9/12/15.
//  Copyright © 2015 Wes Billman. All rights reserved.
//

import XCTest
@testable import React

class CarTests: XCTestCase {
    var car:CarProtocol!
    
    override func setUp() {
        super.setUp()
        car = Car(name: "test")
    }
    
    func testStarting() {
        car.start()
        XCTAssertEqual(car.running.value, true)
    }

    func testStopping() {
        car.start()
        car.stop()
        XCTAssertEqual(car.running.value, false)
    }
}
