//
//  CitiesListViewModel.swift
//  Air Quality
//
//  Created by Anthony Hoang on 1/24/18.
//  Copyright © 2018 Anthony Hoang. All rights reserved.
//

import Foundation
import RxSwift
import PromiseKit

class CitiesListViewModel {

    private var currentPage = 1
    private var cities = Variable<[City]>([])
    private let service = OpenAQService()
    private var queue: DispatchQueue
    private var loadNextPage = true
    
    var rxCities: Observable<[CityViewModel]> {
        return cities.asObservable().map({ $0.map({ CityViewModel(city: $0 )}) })
    }

    private var error = Variable<String?>(nil)
    var rxError: Observable<String?> {
        return error.asObservable()
    }

    init() {
        self.queue = DispatchQueue(label: Constants.PagingThreadName)
    }

    private func fetchCities() -> Promise<[City]> {
        return Promise { [weak self] resolver, _ in
            self?.service.getCities(self?.currentPage ?? 0).then { [weak self] (json) -> Void in
                if let cities = json["results"].array?.map({ City(json: $0) }).flatMap({ $0 }).filter({ $0.measurements > Constants.MinimumMeasurements}) {
                    resolver(cities)
                }

                if let meta = json["meta"].dictionary, let page = meta["page"]?.int {
                    self?.currentPage = page
                }

                }.catch { [weak self] _ in
                    self?.error.value = Constants.GenericErrorMessage
            }
        }
    }

    func reloadCities() {
        self.currentPage = 1
        self.fetchCities().then { [weak self] cities -> Void in
            self?.cities.value = cities
            self?.setCanLoad(true)
        }
    }

    func nextPageIfNeeded() {
        // guard against fast scrolling, don't make network request until previous request has finished
        self.queue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.loadNextPage {
                strongSelf.loadNextPage = false
                strongSelf.currentPage += 1

                strongSelf.fetchCities().then { cities -> Void in
                    strongSelf.cities.value += cities
                    strongSelf.setCanLoad(cities.count != 0) // if there are no more results, don't make any more requests for next page
                }
            }
        }
    }

    private func setCanLoad(_ canLoad: Bool) {
        self.queue.async(flags: .barrier) { [weak self] in
            self?.loadNextPage = canLoad
        }
    }
}

extension CitiesListViewModel {
    private enum Constants {
        static let GenericErrorMessage = "There was a problem loading cities."
        static let MinimumMeasurements = 10000
        static let PagingThreadName = "com.airquality.pagequeue"
    }
}
