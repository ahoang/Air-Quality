//
//  City.swift
//  Air Quality
//
//  Created by Anthony Hoang on 1/24/18.
//  Copyright © 2018 Anthony Hoang. All rights reserved.
//

import Foundation
import SwiftyJSON

class City {

    var name: String
    var country: String
    var measurements: Int

    init?(json: JSON) {

        guard
            let name = json["city"].string,
            let country = json["country"].string,
            let measurements = json["count"].int else {
                return nil
        }

        self.name = name
        self.country = country
        self.measurements = measurements
    }
}

extension City: Equatable {
    static func ==(lhs: City, rhs: City) -> Bool {
        return lhs.name + lhs.country == rhs.name + rhs.country
        && lhs.country == rhs.country
        && lhs.measurements == rhs.measurements
    }
}
