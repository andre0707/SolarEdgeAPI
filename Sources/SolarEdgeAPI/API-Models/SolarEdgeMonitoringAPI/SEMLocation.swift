//
//  SEMLocation.swift
//  
//
//  Created by Andre Albach on 26.03.23.
//

import Foundation

/// A location
public struct SEMLocation: Codable {
    public let country: String
    public let state: String?
    public let city: String
    public let address: String
    public let address2: String
    public let zip: String
    public let timeZone: String
    public let countryCode: String
}
