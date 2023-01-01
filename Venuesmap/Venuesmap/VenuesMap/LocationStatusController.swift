//
//  LocationStatusController.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import Combine
import UIKit

enum LocationStatusState: Equatable {
    case denied
    case notRequested
}

class LocationStatusController: UIViewController {
    
    enum Output {
        case grant
        case toSettings
    }
    
    typealias State = LocationStatusState
    
    var state: State! {
        didSet {
            render(state)
        }
    }
    
    private var cancellable: Cancellable?
    private var output: (Output) -> Void
    
    private lazy var reason: UILabel = {
        .title
    }()
    
    private lazy var actionDescription: UILabel = {
        .title2.multiline()
    }()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton.systemButton(with: .sfLocationGrant, target: self, action: #selector(action(_:)))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = .init(top: 8, left: 20, bottom: 8, right: 20)
        button.imageEdgeInsets = .init(top: 0, left: -2, bottom: 0, right: 2)
        button.titleEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: -2)
        button.layer.borderColor = button.tintColor.cgColor
        button.layer.borderWidth = 2.0
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }()
    
    init(state: AnyPublisher<LocationStatusState, Never>, output: @escaping (Output) -> Void) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
        cancellable = state.removeDuplicates().sink { [weak self] in self?.state = $0 }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
        if let state = state {
            render(state)
        }
    }
    
    private func layout() {
        view.addSubview(reason)
        view.addSubview(actionDescription)
        view.addSubview(image)
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            reason.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 4),
            reason.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: reason.trailingAnchor, multiplier: 2),
            
            actionDescription.topAnchor.constraint(equalToSystemSpacingBelow: reason.bottomAnchor, multiplier: 2),
            actionDescription.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: actionDescription.trailingAnchor, multiplier: 2),
            
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            actionButton.topAnchor.constraint(equalToSystemSpacingBelow: image.bottomAnchor, multiplier: 2),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func render(_ state: LocationStatusState) {
        image.image = .sfLocationSlach
        switch state {
        case .denied:
            reason.text = "Location acces denied"
            actionDescription.text = "Please go to settings and grant location permission for the Placemap"
            actionButton.setTitle("Go to settings", for: .normal)
        case .notRequested:
            reason.text = "Provide you location"
            actionDescription.text = "Placemap will use your location to show most relevant venues around you!"
            actionButton.setTitle("Continue", for: .normal)
        }
    }
    
    @objc private func action(_ sender: UIButton) {
        let action: Output = state == .denied ? .toSettings : .grant
        output(action)
    }
}
