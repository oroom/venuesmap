//
//  Card.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import UIKit

enum CardTypes: String {
    case venue
    
    var type: CardType {
        .init(id: "card." + self.rawValue)
    }
}

/// Unified card type to be used in collections
struct CardType : Identifiable {
    var id: String
}

protocol Card: UIContentConfiguration {
    associatedtype Payload
    
    var cardType: CardType { get }
    var cardPayload: Payload { get }
    var ID: String { get }
}

/// Card to be used with diffable datasources
struct DiffableCard: Hashable {
    let card: any Card
    
    static func == (lhs: DiffableCard, rhs: DiffableCard) -> Bool {
        lhs.card.ID == rhs.card.ID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(card.ID)
    }
}

extension Card {
    var diffable: DiffableCard {
        DiffableCard(card: self)
    }
}
