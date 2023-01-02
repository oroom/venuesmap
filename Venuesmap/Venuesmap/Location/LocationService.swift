//
//  LocationService.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import CoreLocation
import Combine


/// Request request location services acess and subscribe for updates
protocol LocationAvailability {
    var accesUpdates: AnyPublisher<LocationAccess, Never> { get }
    func requestAccessIfPossible()
}

/// Request location and listen for location updates
protocol LocationProvider {
    var locationUpdates: AnyPublisher<CLLocationCoordinate2D, Never> { get }
    func requestLocationIfPossible()
}

final class LocationService: NSObject, LocationAvailability, LocationProvider {
    
    var accesUpdates: AnyPublisher<LocationAccess, Never> { accesState.eraseToAnyPublisher() }
    var locationUpdates: AnyPublisher<CLLocationCoordinate2D, Never> { locationValue.eraseToAnyPublisher() }
    private var authorizationStatus: LocationAccess { locationManager.locationAuthorizationStatus.locationAccess }
    
    private lazy var accesState: CurrentValueSubject = CurrentValueSubject<LocationAccess, Never>(authorizationStatus)
    private lazy var locationValue: PassthroughSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    private var locationManager: LocationManager
    private var isWaitingLocationAcces: Bool = false
    
    init(locationManager: LocationManager = DefaultLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.registerAuthStatusHandler { [ weak self] status in
            guard let self = self else { return }
            self.accesState.send(status.locationAccess)
            if self.isWaitingLocationAcces && status.locationAccess == .granted {
                self.requestLocationIfPossible()
            }
        }
    }
    
    func requestAccessIfPossible() {
        if authorizationStatus == .notRequested {
            locationManager.requestAuthorization()
        }
    }
    
    func requestLocationIfPossible() {
        guard authorizationStatus == .granted else {
            isWaitingLocationAcces = true
            return
        }
            
        isWaitingLocationAcces = false
        locationManager.getLocation { [ weak self] coordinate in
            self?.locationValue.send(coordinate)
        }
    }
    
    func getLocation(_ locationHandler: @escaping (CLLocationCoordinate2D) -> Void) {
        if authorizationStatus == .granted {
            locationManager.getLocation(locationHandler)
        }
    }
}
