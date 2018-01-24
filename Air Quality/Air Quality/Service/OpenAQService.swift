//
//  OpenAQService.swift
//  Air Quality
//
//  Created by Anthony Hoang on 1/24/18.
//  Copyright © 2018 Anthony Hoang. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class OpenAQService {
    func getCities(_ page: Int) -> Promise<JSON> {
        return Promise  { (resolve, reject) in
            let params = ["sort" : "desc", "order_by" : "count"]
            Alamofire.request(Constants.url, parameters: params).responseJSON(completionHandler: { (response) in
                do {
                    if let data = response.data {
                        let json = try JSON(data: data)
                        resolve(json)
                    } else if let error = response.error {
                        reject(error)
                    }
                } catch {
                    reject(error)
                }
            })
        }
    }
}

extension OpenAQService {
    enum Constants {
        static let url = "https://api.openaq.org/v1/cities"
    }
}
