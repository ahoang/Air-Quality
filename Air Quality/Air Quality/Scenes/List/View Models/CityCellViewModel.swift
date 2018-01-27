//
//  CityCellViewModel.swift
//  Air Quality
//
//  Created by Anthony Hoang on 1/24/18.
//  Copyright © 2018 Anthony Hoang. All rights reserved.
//

import Foundation
import RxDataSources

class CityCellViewModel {
    fileprivate var city: City

    var titleText: String {
        return city.name + ", " + city.country
    }

    var subtitleText: String? {
        return "Number of measurements: " + formatNumber(city.measurements)
    }

    init(city: City) {
        self.city = city
    }

    private func formatNumber(_ number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(integerLiteral: number)) ?? ""
    }
}

extension CityCellViewModel: Equatable {
    static func ==(lhs: CityCellViewModel, rhs: CityCellViewModel) -> Bool {
        return lhs.city == rhs.city

    }
}

extension CityCellViewModel: IdentifiableType {

    var identity: String {
        return city.name + city.country
    }
}
