//
//  VenuesDTOGenerated.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation

// MARK: - VenuesList
struct VenuesList: Codable {
    let results: [Venue]
}

struct Venue: Codable {
    let fsqID: String
    let categories: [Category]
    let chains: [Chain]
    let distance: Int
    let geocodes: Geocodes
    let link: String
    let location: Location
    let name: String
    let relatedPlaces: RelatedPlaces
    let timezone: String

    enum CodingKeys: String, CodingKey {
        case fsqID = "fsq_id"
        case categories, chains, distance, geocodes, link, location, name
        case relatedPlaces = "related_places"
        case timezone
    }
}

// MARK: - Category
struct Category: Codable {
    let id: Int
    let name: String
    let icon: Icon
}

// MARK: - Icon
struct Icon: Codable {
    let iconPrefix: String
    let suffix: Suffix

    enum CodingKeys: String, CodingKey {
        case iconPrefix = "prefix"
        case suffix
    }
}

enum Suffix: String, Codable {
    case png = ".png"
}

// MARK: - Chain
struct Chain: Codable {
    let id, name: String
}

// MARK: - Geocodes
struct Center: Codable {
    let latitude, longitude: Double
}

struct Geocodes: Codable {
    let main: Center
    let roof: Center?
}

// MARK: - Location
struct Location: Codable {
    let address, censusBlock: String
    let country: Country
    let crossStreet: String?
    let dma: DMA
    let formattedAddress: String
    let locality: Locality
    let neighborhood: [Neighborhood]
    let postcode: String
    let region: Region
    let addressExtended: String?

    enum CodingKeys: String, CodingKey {
        case address
        case censusBlock = "census_block"
        case country
        case crossStreet = "cross_street"
        case dma
        case formattedAddress = "formatted_address"
        case locality, neighborhood, postcode, region
        case addressExtended = "address_extended"
    }
}

enum Country: String, Codable {
    case us = "US"
}

enum DMA: String, Codable {
    case seattleTacoma = "Seattle-Tacoma"
}

enum Locality: String, Codable {
    case seattle = "Seattle"
}

enum Neighborhood: String, Codable {
    case broadway = "Broadway"
    case capitolOne = "Capitol One"
}

enum Region: String, Codable {
    case wa = "WA"
}

// MARK: - RelatedPlaces
struct RelatedPlaces: Codable {
    let parent: Parent?
}

// MARK: - Parent
struct Parent: Codable {
    let fsqID, name: String

    enum CodingKeys: String, CodingKey {
        case fsqID = "fsq_id"
        case name
    }
}
