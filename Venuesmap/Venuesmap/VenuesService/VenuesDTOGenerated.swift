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
    let distance: Int
    let geocodes: Geocodes
    let location: Location?
    let link: String?
    let name: String

    enum CodingKeys: String, CodingKey {
        case fsqID = "fsq_id"
        case categories, distance, geocodes, link, name, location
    }
}

// MARK: - Location
struct Location: Codable {
    let address: String?


    enum CodingKeys: String, CodingKey {
        case address
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
    let suffix: String?

    enum CodingKeys: String, CodingKey {
        case iconPrefix = "prefix"
        case suffix
    }
}

// MARK: - Geocodes
struct Center: Codable {
    let latitude, longitude: Double
}

struct Geocodes: Codable {
    let main: Center
    let roof: Center?
}
