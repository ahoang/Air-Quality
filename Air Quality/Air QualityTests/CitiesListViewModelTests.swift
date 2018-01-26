//
//  CitiesListViewModelTests.swift
//  Air QualityTests
//
//  Created by Anthony Hoang on 1/25/18.
//  Copyright © 2018 Anthony Hoang. All rights reserved.
//
@testable import Air_Quality
import XCTest
import OHHTTPStubs
import RxSwift

class CitiesListViewModelTests: XCTestCase {

    var disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        OHHTTPStubs.setEnabled(true)
        stub(condition: { (request) -> Bool in
            return request.url?.host ?? "" == "api.openaq.org"
        }) { (_) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("cities.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRX() {
        let expectation = self.expectation(description: #function)
        let viewModel = CitiesListViewModel()

        viewModel.rxCities.bind { (viewModels) in
            if viewModels.count > 0 { // first binding is empty array
                XCTAssertEqual(viewModels.count, 100)
                expectation.fulfill()
            }
        }.disposed(by: disposeBag)

        viewModel.reloadCities()

        self.wait(for: [expectation], timeout: 10)
    }

    func testPaging() {
        let expectation = self.expectation(description: #function)
        let viewModel = CitiesListViewModel()
        var pageNumber = 1

        viewModel.rxCities.bind { (viewModels) in
            if viewModels.count > 0 { // first binding is empty array
                if pageNumber == 1 {
                    XCTAssertEqual(viewModels.count, 100)
                    pageNumber = 2
                    viewModel.nextPageIfNeeded()
                }else if pageNumber == 2 {
                    XCTAssertEqual(viewModels.count, 200)
                    expectation.fulfill()
                }
            }

            }.disposed(by: disposeBag)

        viewModel.reloadCities()
        self.wait(for: [expectation], timeout: 10)
    }

    func testError() {
        stub(condition: { (request) -> Bool in
            return request.url?.host ?? "" == "api.openaq.org"
        }) { (_) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse.init(error: NSError(domain: "", code: 0, userInfo: nil))
        }

        let expectation = self.expectation(description: #function)
        let viewModel = CitiesListViewModel()

        viewModel.rxCities.bind { (viewModels) in
            if viewModels.count > 0 { // first binding is empty array
               XCTFail()
            }

            }.disposed(by: disposeBag)

        viewModel.rxError.bind { (message) in
            if let message = message { //first binding is nil
                XCTAssertEqual(message, "There was a problem loading cities.")
                expectation.fulfill()
            }
        }.disposed(by: disposeBag)

        viewModel.reloadCities()
        self.wait(for: [expectation], timeout: 10)
    }

    // do not return cities with less than 10000 measurements
    func testMinimumMeasurements() {
        stub(condition: { (request) -> Bool in
            return request.url?.host ?? "" == "api.openaq.org"
        }) { (_) -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("cities_minimum.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }

        let expectation = self.expectation(description: #function)
        let viewModel = CitiesListViewModel()

        viewModel.rxCities.bind { (viewModels) in
            if viewModels.count > 0 { // first binding is empty array
                XCTAssertEqual(18, viewModels.count)
                expectation.fulfill()
            }

            }.disposed(by: disposeBag)

        viewModel.reloadCities()
        self.wait(for: [expectation], timeout: 10)
    }
}
