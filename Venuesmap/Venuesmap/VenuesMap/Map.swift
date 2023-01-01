//
//  Map.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import MapKit

final class Map: UIView {
    
    private var map: MKMapView
    
    override init(frame: CGRect) {
        map = MKMapView(frame: frame)
        super.init(frame: frame)
        NSLayoutConstraint.add(subview: map, to: self)
        map.setCenter(.init(latitude: 47.6315, longitude: -122.3264), animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NSLayoutConstraint {
    static func add(subview: UIView, to superview: UIView) {
        superview.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: superview.topAnchor),
            subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
}
