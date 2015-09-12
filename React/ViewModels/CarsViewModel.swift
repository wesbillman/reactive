//
//  CarsViewModel.swift
//  React
//
//  Created by Wes Billman on 9/11/15.
//  Copyright © 2015 Wes Billman. All rights reserved.
//

import Foundation
import RxSwift

protocol CarsViewModelProtocol {
    var cars:ObservableCollection<CarProtocol> { get }
    func addCar(car:CarProtocol)
}

class CarsViewModel : ViewModelBase, CarsViewModelProtocol {
    var cars = ObservableCollection<CarProtocol>()
    
    init(cars:[CarProtocol]) {
        self.cars.appendContentsOf(cars)
        super.init()
    }
    
    func addCar(car: CarProtocol) {
        cars.insert(car, atIndex: 0)
    }
}