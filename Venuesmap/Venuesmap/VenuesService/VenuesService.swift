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
    
    /// All parameters are documented here:  https://location.foursquare.com/developer/reference/place-search
    /// "ne=47.6311,-122.3164"
    /// "sw=47.6019,-122.3319"
    func getVenues(with ne: CLLocationCoordinate2D, and sw: CLLocationCoordinate2D, session: URLSession) -> AnyPublisher<VenuesList, any Error>
}

final class VenuesServiceImpl: VenuesService {
    
    func getVenues(with ne: CLLocationCoordinate2D, and sw: CLLocationCoordinate2D, session: URLSession = .shared) -> AnyPublisher<VenuesList, any Error> {
        let request = Endpoint.placesSearch.request!
        return session.dataTaskPublisher(for: request)
                    .map(\.data)
                    .decode(type: VenuesList.self, decoder: JSONDecoder())
                    .eraseToAnyPublisher()
    }
}
