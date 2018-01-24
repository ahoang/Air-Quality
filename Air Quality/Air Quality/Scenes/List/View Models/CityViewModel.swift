//
//  CityViewModel.swift
//  Air Quality
//
//  Created by Anthony Hoang on 1/24/18.
//  Copyright © 2018 Anthony Hoang. All rights reserved.
//

import Foundation

class CityViewModel {
    var city: City

    init(city: City) {
        self.city = city
    }
}

extension CityViewModel: Equatable {
    static func ==(lhs: CityViewModel, rhs: CityViewModel) -> Bool {
        return lhs.city == rhs.city
    }
}
