//
//  CarsViewModel.swift
//  React
//
//  Created by Wes Billman on 9/11/15.
//  Copyright © 2015 Wes Billman. All rights reserved.
//

import Foundation
import RxSwift

class CarsViewModel : ViewModelBase {
    var cars = ObservableCollection<Car>()
    
    init(cars:[Car]) {
        self.cars.appendContentsOf(cars)
        super.init()
    }
}