//
//  CarViewModelTests.swift
//  Reactive
//
//  Created by Wes Billman on 9/12/15.
//  Copyright © 2015 Wes Billman. All rights reserved.
//

import XCTest
@testable import Reactive

class CarViewModelTests : XCTestCase {

    var viewModel:CarViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = CarViewModel(car: Car(name: "test"))
    }

    func testStartingCar() {
        viewModel.startCar()
        XCTAssertEqual(viewModel.car.running.value, true)
    }
    
    func testStoppingCar() {
        viewModel.startCar()
        viewModel.stopCar()
        XCTAssertEqual(viewModel.car.running.value, false)
    }
}
