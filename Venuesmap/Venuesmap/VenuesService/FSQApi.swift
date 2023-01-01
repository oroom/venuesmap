//
//  FSQApi.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import Combine
import CoreLocation

struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
    var request: URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.foursquare.com"
        components.path = path
        components.queryItems = queryItems
        guard let url = components.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue("fsq3Nqz2qiAz72buRedfkjpKZQX1UIl+nJfNL2yVMALMrFQ=", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

extension Endpoint {
    static var placesSearch: Self {
        Endpoint(
            path: "/v3/places/search",
            queryItems: [
                .init(name: "query", value: "coffee"),
                .init(name: "ne", value: "47.6311,-122.3164"),
                .init(name: "sw", value: "47.6019,-122.3319"),
                .init(name: "sort", value: "DISTANCE")
            ]
        )
    }
}
