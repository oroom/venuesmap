//
//  VenuesService.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import Combine
import CoreLocation

protocol VenuesService {
    func getVenues(inRect: CoordinateRect, session: URLSession) -> AnyPublisher<VenuesList, any Error>
}

final class VenuesServiceImpl: VenuesService {
    
    func getVenues(inRect: CoordinateRect, session: URLSession = .shared) -> AnyPublisher<VenuesList, any Error> {
        let request = FSQEndpoint.coffeePlacesSearch(inRect: inRect).request!
        return session.dataTaskPublisher(for: request)
                    .map(\.data)
                    .decode(type: VenuesList.self, decoder: JSONDecoder())
                    .eraseToAnyPublisher()
    }
}
