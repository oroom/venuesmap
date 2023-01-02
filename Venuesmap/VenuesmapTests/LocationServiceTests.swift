//
//  VenuesmapTests.swift
//  VenuesmapTests
//
//  Created by oroom on 2023-01-01.
//

import XCTest
import CoreLocation
import Combine
@testable import Venuesmap

final class LocationServiceTests: XCTestCase {
    
    private var service: LocationService!
    private var bag: Set<AnyCancellable>!
    private var accessUpdates: [LocationAccess]!
    private var locationUpdates: [CLLocationCoordinate2D]!
    private var locationManagerMock: LocationManagerMock!

    override func setUpWithError() throws {
        locationManagerMock = LocationManagerMock()
        service = LocationService(locationManager: locationManagerMock)
        bag = []
        accessUpdates = []
        locationUpdates = []
    }

    func testServiceUpdateToAccepted() throws {
        
        let expectation = self.expectation(description: "update")
        expectation.expectedFulfillmentCount = 2
        service.accesUpdates
            .sink { access in
                self.accessUpdates.append(access)
                expectation.fulfill()
            }
            .store(in: &bag)
        
        locationManagerMock.locationAuthorizationStatus = .authorizedWhenInUse
        locationManagerMock.handler(.authorizedWhenInUse)
        
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(accessUpdates, [.notRequested, .granted])
    }
    
    func testServiceUpdateToDenied() throws {
        
        let expectation = self.expectation(description: "update")
        expectation.expectedFulfillmentCount = 2
        service.accesUpdates
            .sink { access in
                self.accessUpdates.append(access)
                expectation.fulfill()
            }
            .store(in: &bag)
        
        locationManagerMock.locationAuthorizationStatus = .denied
        locationManagerMock.handler(.denied)
        
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(accessUpdates, [.notRequested, .denied])
    }
    
    func testServiceUpdateFromGrantedToDenied() throws {
        
        locationManagerMock.locationAuthorizationStatus = .authorizedWhenInUse
        
        let expectation = self.expectation(description: "update")
        expectation.expectedFulfillmentCount = 2
        service.accesUpdates
            .sink { access in
                self.accessUpdates.append(access)
                expectation.fulfill()
            }
            .store(in: &bag)
        
        locationManagerMock.locationAuthorizationStatus = .denied
        locationManagerMock.handler(.denied)
        
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(accessUpdates, [.granted, .denied])
    }
    
    func testServiceReturnLocationIfAuthorized() throws {
        
        locationManagerMock.locationAuthorizationStatus = .authorizedWhenInUse
        
        let expectation = self.expectation(description: "update")
        service.locationUpdates
            .sink { coordinate in
                self.locationUpdates.append(coordinate)
                expectation.fulfill()
            }
            .store(in: &bag)
        
        service.requestLocationIfPossible()
        
        waitForExpectations(timeout: 0.1)
        XCTAssert(locationUpdates.count == 1)
    }
    
    func testServiceReturnLocationAfterAuthorization() throws {
        
        locationManagerMock.locationAuthorizationStatus = .denied
        
        let expectation = self.expectation(description: "update")
        service.locationUpdates
            .sink { coordinate in
                self.locationUpdates.append(coordinate)
                expectation.fulfill()
            }
            .store(in: &bag)
        
        service.requestLocationIfPossible()
        XCTAssert(locationUpdates.isEmpty)
        
        locationManagerMock.locationAuthorizationStatus = .authorizedWhenInUse
        locationManagerMock.handler(.authorizedWhenInUse)
        waitForExpectations(timeout: 0.1)
        XCTAssert(locationUpdates.count == 1)
    }

}

final class LocationManagerMock: LocationManager {
    var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var handler: (CLAuthorizationStatus) -> Void = { _ in }
    func registerAuthStatusHandler(_ handler: @escaping (CLAuthorizationStatus) -> Void) {
        self.handler = handler
    }
    
    var requestAuthorizationCalled: Bool = false
    func requestAuthorization() {
        requestAuthorizationCalled = true
    }
    
    func getLocation(_ locationHandler: @escaping (CLLocationCoordinate2D) -> Void) {
        locationHandler(.init(latitude: 0, longitude: 0))
    }
}
