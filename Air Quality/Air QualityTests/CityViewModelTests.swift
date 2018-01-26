//
//  CityViewModel.swift
//  Air QualityTests
//
//  Created by Anthony Hoang on 1/25/18.
//  Copyright © 2018 Anthony Hoang. All rights reserved.
//

@testable import Air_Quality
import XCTest
import OHHTTPStubs
import SwiftyJSON

class CityViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNumberFormatting() {
        let data: [String : Any] = ["city" : "Chicago", "country" : "US", "count" : 678921]
        let json = JSON(data)
        if let city = City(json: json) {
            let viewModel = CityCellViewModel(city: city)
            XCTAssertEqual(viewModel.measurements ?? "", "Number of measurements: 678,921")
        } else {
            XCTFail()
        }
    }
}
