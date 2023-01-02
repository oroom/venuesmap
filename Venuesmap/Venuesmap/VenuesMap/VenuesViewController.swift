//
//  VenuesViewController.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import UIKit
import MapKit
import Combine

protocol ViewsFactory {}

final class ViewsFactoryImpl: ViewsFactory {
}

struct VenuesViewControllerStyle {
    static let `default`: Self = .init()
}

struct VenuesViewControllerState {
    var coordinate: CLLocationCoordinate2D?
    var venues: [Venue]
    
    static let initial: Self = .init(coordinate: nil, venues: [])
}

class VenuesViewController: UIViewController {
    let venuesService = VenuesServiceImpl()
    let locationProvider: LocationProvider
    private var bag: Set<AnyCancellable> = []
    private let style: VenuesViewControllerStyle
    private let cardsFactory: ViewsFactory
    private let loader = UIActivityIndicatorView.init(style: .large)
    private let noContent = UILabel()
    private var state: VenuesViewControllerState = .initial
    
    enum Section {
        case map
        case venues
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, DiffableCard>! = nil
    lazy var venuesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    private var map: (UIView & UIContentView)?
    private lazy var mapPlaceholder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(style: VenuesViewControllerStyle = .default, cardsFactory: ViewsFactory = ViewsFactoryImpl(), locationProvider: LocationProvider) {
        self.style = style
        self.cardsFactory = cardsFactory
        self.locationProvider = locationProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureDataSource()
        
        locationProvider.locationUpdates
            .receive(on: DispatchQueue.main)
            .sink { coordinate in
                self.state.coordinate = coordinate
                self.render()
            }
            .store(in: &bag)
        
        locationProvider.requestLocationIfPossible()
    }
}

private extension VenuesViewController {
    func updateVenues(inRect: CoordinateRect) {
        venuesService.getVenues(inRect: inRect)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                // request finished
            }, receiveValue: { venuesResponce in
                self.state.venues = venuesResponce.results
                self.render()
            })
            .store(in: &bag)
    }
    
    func configureViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(mapPlaceholder)
        view.addSubview(venuesCollectionView)
        view.addSubview(loader)
        view.addSubview(noContent)
        
        NSLayoutConstraint.activate([
            mapPlaceholder.topAnchor.constraint(equalTo: view.topAnchor),
            mapPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapPlaceholder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapPlaceholder.heightAnchor.constraint(equalTo: mapPlaceholder.widthAnchor)
        ])
        NSLayoutConstraint.activate([
            venuesCollectionView.topAnchor.constraint(equalTo: mapPlaceholder.bottomAnchor),
            venuesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            venuesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            venuesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        loader.translatesAutoresizingMaskIntoConstraints = false
        noContent.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        NSLayoutConstraint.activate([
            noContent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noContent.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    func configureDataSource() {
        
        let mapCell = UICollectionView.CellRegistration<UICollectionViewCell, DiffableCard> { cell, _, item in
            cell.contentConfiguration = item.card
        }
        
        let venueCell = UICollectionView.CellRegistration<UICollectionViewCell, DiffableCard> { cell, _, item in
            cell.contentConfiguration = item.card
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, DiffableCard>(collectionView: venuesCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: DiffableCard)
            -> UICollectionViewCell? in
            
            if indexPath.section == 0 {
                return collectionView.dequeueConfiguredReusableCell(using: mapCell, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: venueCell, for: indexPath, item: item)
            }
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let estimatedSize = UIScreen.main.bounds.width
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedSize))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 16, bottom: .zero, trailing: 16)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedSize))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16

        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        return layout
    }
    
    func render() {
        // Map
        let venuesPins = state.venues.map { venue in
            let point = MKPointAnnotation()
            point.title = venue.name
            point.coordinate = .init(latitude: venue.geocodes.main.latitude, longitude: venue.geocodes.main.longitude)
            return point
        }
        
        let venuesMap = MapCard(cardPayload: .init(location: state.coordinate, points: venuesPins)) { [weak self] region in
            self?.updateVenues(inRect: region)
        }
        
        if let map = map {
            map.configuration = venuesMap
        } else {
            let newMap = venuesMap.makeContentView()
            NSLayoutConstraint.add(subview: newMap, to: mapPlaceholder)
            map = newMap
        }
        
        // List
        let venueCards = state.venues.map { venue in
            VenueCard(cardPayload: .init(venueName: venue.name, address: venue.location?.address), ID: venue.fsqID).diffable
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, DiffableCard>()
        
        if !venueCards.isEmpty {
            snapshot.appendSections([.venues])
            snapshot.appendItems(venueCards, toSection: .venues)
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
