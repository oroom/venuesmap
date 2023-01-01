//
//  LocationService.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import CoreLocation
import Combine

protocol LocationAvailability {
    var accesUpdates: AnyPublisher<LocationAccess, Never> { get }
    func requestAccessIfPossible()
}

final class LocationService: NSObject, LocationAvailability {
    
    var accesUpdates: AnyPublisher<LocationAccess, Never> { state.eraseToAnyPublisher() }
    var authorizationStatus: CLAuthorizationStatus { locationManager.locationAuthorizationStatus }
    
    private lazy var state: CurrentValueSubject = CurrentValueSubject<LocationAccess, Never>(authorizationStatus.locationAccess)
    private var locationManager: LocationManager
    
    init(locationManager: LocationManager = DefaultLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.registerAuthStatusHandler { [ weak self] status in
            self?.state.send(status.locationAccess)
        }
    }
    
    func requestAccessIfPossible() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAuthorization()
        }
    }
}
