//
//  Router.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import Combine
import UIKit

final class MainRouter {
    private var locationAvailability: LocationAvailability
    private(set) var topViewController: UIViewController
    private var bag = Set<AnyCancellable>()
    
    init(initialVC: UIViewController = VenuesController(), locationAvailability: LocationAvailability = LocationService()) {
        self.locationAvailability = locationAvailability
        self.topViewController = UINavigationController(rootViewController: initialVC)
        
        locationAvailability.accesUpdates
            .subscribe(on: DispatchQueue.main)
            .map { access -> Bool in
                access != .granted
            }
            .removeDuplicates()
            .sink { [weak self] disabled in
                guard let `self` = self else { return }
                if disabled {
                    self.showLocationAccess()
                } else {
                    self.topViewController.dismiss(animated: true)
                }
            }.store(in: &bag)
    }
    
    func showLocationAccess() {
        let locationRequestController = LocationStatusController(
            state: locationAvailability.accesUpdates
                .map { $0 == .denied ? LocationStatusState.denied : LocationStatusState.notRequested }
                .eraseToAnyPublisher()) { output in
                    switch output {
                    case .grant:
                        self.locationAvailability.requestAccessIfPossible()
                    case .toSettings:
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            // Ask the system to open that URL.
                            UIApplication.shared.open(url)
                        }
                    }
                }
        locationRequestController.isModalInPresentation = true
        topViewController.present(locationRequestController, animated: true)
    }
}
