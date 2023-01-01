//
//  VenuesController.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import UIKit
import Combine

class VenuesController: UIViewController {
    typealias State = ()
    
    private lazy var map: Map = {
        let map = Map()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.backgroundColor = .systemRed
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
        render(())
    }
    
    private func layout() {
        view.addSubview(map)
        
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.heightAnchor.constraint(equalTo: map.widthAnchor)
        ])
    }
    
    private func render(_ state: State) {
        
    }
}
