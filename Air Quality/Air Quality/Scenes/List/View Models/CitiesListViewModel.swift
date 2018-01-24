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

    private var currentPage = 0
    private var cities = Variable<[City]>([])
    private let service = OpenAQService()
    var rxCities: Observable<[CityViewModel]> {
        return cities.asObservable().map({ $0.map({ CityViewModel(city: $0 )}) })
    }

    private func fetchCities() -> Promise<[City]> {
        return Promise { [weak self] resolver, _ in
            service.getCities(self?.currentPage ?? 0).then { [weak self] (json) -> Void in
                if let cities = json["results"].array?.map({ City(json: $0) }).flatMap({ $0 }) {
                    resolver(cities)
                }

                if let meta = json["meta"].dictionary, let page = meta["page"]?.int {
                    self?.currentPage = page
                }
            }
        }
    }

    func reloadCities() {
        self.currentPage = 0
        self.fetchCities().then { [weak self] cities -> Void in
            self?.cities.value = cities
        }
    }

    func nextPage() {
        self.fetchCities().then { [weak self] cities -> Void in
            self?.cities.value += cities
        }
    }
}
