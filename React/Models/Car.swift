//
//  Car.swift
//  React
//
//  Created by Wes Billman on 9/11/15.
//  Copyright © 2015 Wes Billman. All rights reserved.
//

import Foundation
import RxSwift

class Car {
    var name = Variable("")
    var running = Variable(false)
    
    init(name:String) {
        self.name.value = name
    }
    
    func start() {
        running.value = true
    }
    
    func stop() {
        running.value = false
    }
}