//
//  VenueCard.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import UIKit

final class VenueCard: Card {
    struct Props {
        let venueName: String
        let address: String?
    }
    
    var cardType = CardTypes.venue.type
    var cardPayload: Props
    var ID: String
    
    init(cardPayload: Props, ID: String) {
        self.cardPayload = cardPayload
        self.ID = ID
    }
}

extension VenueCard {
    func makeContentView() -> UIView & UIContentView {
        VenueCardView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}

final class VenueCardView: UIView & UIContentView {
    let name = UILabel.headline
    let subtitle = UILabel.subheadline.multiline()
    
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    
    init(configuration: VenueCard) {
        self.configuration = configuration
        super.init(frame: .zero)
        addSubview(name)
        addSubview(subtitle)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? VenueCard else { return }
        name.text = configuration.cardPayload.venueName
        if let address = configuration.cardPayload.address {
            subtitle.text = "Address: \(address)"
        } else {
            subtitle.text = nil
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            name.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
        NSLayoutConstraint.activate([
            subtitle.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8),
            subtitle.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: name.trailingAnchor),
            subtitle.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
