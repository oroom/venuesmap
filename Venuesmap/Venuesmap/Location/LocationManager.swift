//
//  LocationManager.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import CoreLocation

enum LocationAccess {
    case notRequested
    case denied
    case granted
}

protocol LocationManager {
    var locationAuthorizationStatus: CLAuthorizationStatus { get }
    func requestAuthorization()
    func registerAuthStatusHandler(_ handler: @escaping (CLAuthorizationStatus) -> Void)
    func getLocation(_ locationHandler: @escaping (CLLocationCoordinate2D) -> Void)
}

final class DefaultLocationManager: NSObject, LocationManager, CLLocationManagerDelegate {
    var locationAuthorizationStatus: CLAuthorizationStatus { manager.authorizationStatus }
    private var handler: (CLAuthorizationStatus) -> Void = { _ in }
    private var locationHandler: (CLLocationCoordinate2D) -> Void = { _ in }
    
    private lazy var manager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.distanceFilter = 50
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return manager
    }()
    
    override init() {
        super.init()
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func registerAuthStatusHandler(_ handler: @escaping (CLAuthorizationStatus) -> Void) {
        self.handler = handler
        manager.delegate = self
    }
    
    func getLocation(_ locationHandler: @escaping (CLLocationCoordinate2D) -> Void) {
        self.locationHandler = locationHandler
        manager.startUpdatingLocation()
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handler(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationHandler(location.coordinate)
            locationHandler = { _ in }
            manager.stopUpdatingLocation()
        }
    }
}

extension CLAuthorizationStatus {
    var locationAccess: LocationAccess {
        switch self {
        case .notDetermined :
            return .notRequested
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }
}
