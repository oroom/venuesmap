//
//  Map.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import Combine
import MapKit

final class MapCard: UIContentConfiguration {
    struct Props {
        let location: CLLocationCoordinate2D?
        let points: [MKPointAnnotation]
    }
    
    var cardPayload: Props
    var regionChangedHandler: (CoordinateRect) -> ()
    
    init(cardPayload: Props, regionChangedHandler: @escaping (CoordinateRect) -> ()) {
        self.cardPayload = cardPayload
        self.regionChangedHandler = regionChangedHandler
    }
}

extension MapCard {
    func makeContentView() -> UIView & UIContentView {
        MapCardView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}

final class MapCardView: UIView, UIContentView, MKMapViewDelegate {
    
    let map = MKMapView()
    private var lastUsedRegion: MKCoordinateRegion?
    private var lastUserCoordinate: CLLocationCoordinate2D?
    var regionChangedHandler: (CoordinateRect) -> () = { _ in }
    
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    
    init(configuration: MapCard) {
        self.configuration = configuration
        super.init(frame: .zero)
        NSLayoutConstraint.add(subview: map, to: self)
        map.showsUserLocation = true
        map.delegate = self
        configure(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? MapCard else { return }
        regionChangedHandler = configuration.regionChangedHandler
        if lastUserCoordinate == nil, let coordinate = configuration.cardPayload.location {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            map.setRegion(region, animated: true)
            lastUserCoordinate = configuration.cardPayload.location
        }
        let mapPoints = Set(map.annotations.compactMap{ $0 as? MKPointAnnotation })
        let cardPoints = Set(configuration.cardPayload.points)
        map.removeAnnotations(Array(mapPoints.subtracting(cardPoints)))
        map.addAnnotations(Array(cardPoints.subtracting(mapPoints)))
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "venue.annoation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.region.hasSignificantDifference(with: lastUsedRegion) {
            lastUsedRegion = mapView.region
            regionChangedHandler(mapView.region.coordinates)
        }
    }
}

typealias CoordinateRect = (ne: CLLocationCoordinate2D, sw: CLLocationCoordinate2D)
extension MKCoordinateRegion {
    var coordinates: CoordinateRect {
        let ne = CLLocationCoordinate2D(
            latitude: center.latitude + span.latitudeDelta.magnitude/2,
            longitude: center.longitude + span.latitudeDelta.magnitude/2
        )
        let sw = CLLocationCoordinate2D(
            latitude: center.latitude - span.latitudeDelta.magnitude/2,
            longitude: center.longitude - span.latitudeDelta.magnitude/2
        )
        return (ne: ne, sw: sw)
    }
    
    func hasSignificantDifference(with newRegion: MKCoordinateRegion?) -> Bool {
        guard let newRegion = newRegion else {
            return true
        }
        let treshold: Double = 100
        if MKMapPoint(center).distance(to: .init(newRegion.center)) > treshold {
            return true
        }
        if span.longitudeDelta.magnitude - newRegion.span.longitudeDelta.magnitude > treshold/111000 {
            return true
        }
        return true
    }
}
