//
//  CarViewModel.swift
//  Reactive
//
//  Created by Wes Billman on 9/11/15.
//  Copyright © 2015 Wes Billman. All rights reserved.
//

import Foundation
import RxSwift

class CarViewModel : ViewModelBase {
    var car:CarProtocol
    
    init(car:CarProtocol) {
        self.car = car
        super.init()
    }
    
    func startCar() {
        car.start()
    }
    
    func stopCar() {
        car.stop()
    }
}